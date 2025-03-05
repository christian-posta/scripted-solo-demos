#!/usr/bin/env python3
import argparse
import asyncio
import aiohttp
import time
import json
import subprocess
import random
import math
import threading
from faker import Faker
from typing import Dict, Any, List, Callable


async def get_gateway_info() -> tuple:
    """Get the gateway IP and port from kubectl."""
    try:
        ip_process = subprocess.run(
            ["kubectl", "get", "gateway/inference-gateway", "-o", "jsonpath='{.status.addresses[0].value}'"],
            capture_output=True,
            text=True,
            check=True
        )
        ip = ip_process.stdout.strip("'")
        port = 8081
        return ip, port
    except subprocess.CalledProcessError as e:
        print(f"Error getting gateway info: {e}")
        return None, None


def generate_random_prompt() -> str:
    """Generate a random tweet-related prompt."""
    fake = Faker()
    
    tweet_topics = [
        "technology", "politics", "sports", "entertainment", "food", 
        "travel", "health", "business", "science", "education"
    ]
    
    tweet_styles = [
        "humorous", "serious", "informative", "controversial", "inspirational",
        "sarcastic", "promotional", "questioning", "celebratory", "critical"
    ]
    
    tweet_formats = [
        "Write a tweet about {topic} that is {style}",
        "Compose a {style} tweet discussing recent developments in {topic}",
        "Create a {style} tweet that would go viral about {topic}",
        "Draft a tweet for a {topic} influencer that sounds {style}",
        "Write a {style} tweet announcing breaking news in {topic}",
        "Compose a tweet thread starter about {topic} with a {style} tone",
        "Create a tweet that would get many retweets about {topic} using a {style} approach",
        "Write a tweet responding to controversy in the {topic} world with a {style} take",
        "Draft a {style} tweet that would trend worldwide about {topic}",
        "Compose a tweet that a celebrity might post about {topic} with a {style} voice"
    ]
    
    # Add some specific entities to make prompts more interesting
    if random.random() < 0.5:
        topic = random.choice(tweet_topics)
    else:
        if random.random() < 0.3:
            topic = fake.company()
        elif random.random() < 0.6:
            topic = fake.catch_phrase()
        else:
            topic = fake.bs()
    
    style = random.choice(tweet_styles)
    format_template = random.choice(tweet_formats)
    
    # Sometimes add extra context to make the prompt longer
    extra_context = ""
    if random.random() < 0.7:
        context_templates = [
            f" Include a reference to {fake.name()}.",
            f" Mention the city of {fake.city()}.",
            f" Include a trending hashtag like #{fake.word().replace(' ', '')}Day.",
            f" Reference the recent event: {fake.sentence()}",
            f" Make it appeal to {fake.job()} professionals.",
            f" Include a call to action for readers to {fake.bs()}.",
            f" Make sure it would resonate with people interested in {fake.catch_phrase()}.",
            f" Include a subtle reference to {fake.company()} without naming them directly."
        ]
        extra_context = random.choice(context_templates)
        
        # Sometimes add even more context to reach closer to 100 tokens
        if random.random() < 0.4:
            extra_context += random.choice(context_templates)
    
    prompt = format_template.format(topic=topic, style=style) + extra_context
    
    # Add length requirements occasionally
    if random.random() < 0.3:
        prompt += f" Keep it under {random.randint(200, 280)} characters."
    
    return prompt


async def make_request(session: aiohttp.ClientSession, url: str, payload: Dict[str, Any], request_id: int) -> Dict[str, Any]:
    """Make a single request to the API."""
    start_time = time.time()
    try:
        async with session.post(url, json=payload) as response:
            elapsed = time.time() - start_time
            status = response.status
            
            # Try to get response data, but handle potential JSON parsing errors
            try:
                response_data = await response.json()
            except Exception as json_error:
                # If JSON parsing fails, get the raw text
                response_text = await response.text()
                response_data = {"error": f"Failed to parse JSON: {str(json_error)}", "raw_response": response_text[:500]}
            
            result = {
                "request_id": request_id,
                "status": status,
                "elapsed_time": elapsed,
                "prompt": payload.get("prompt", ""),
                "response": response_data,
                "timestamp": time.time()
            }
            
            # Add error details for non-200 responses
            if status != 200:
                result["error_details"] = {
                    "status_code": status,
                    "status_message": response.reason,
                    "headers": dict(response.headers),
                    "response_data": response_data
                }
            
            return result
            
    except aiohttp.ClientConnectorError as e:
        elapsed = time.time() - start_time
        return {
            "request_id": request_id,
            "status": "connection_error",
            "elapsed_time": elapsed,
            "prompt": payload.get("prompt", ""),
            "error": f"Connection error: {str(e)}",
            "error_details": {"type": "connection_error", "message": str(e)},
            "timestamp": time.time()
        }
    except aiohttp.ClientResponseError as e:
        elapsed = time.time() - start_time
        return {
            "request_id": request_id,
            "status": e.status,
            "elapsed_time": elapsed,
            "prompt": payload.get("prompt", ""),
            "error": f"Response error: {str(e)}",
            "error_details": {"type": "response_error", "status": e.status, "message": str(e)},
            "timestamp": time.time()
        }
    except asyncio.TimeoutError:
        elapsed = time.time() - start_time
        return {
            "request_id": request_id,
            "status": "timeout",
            "elapsed_time": elapsed,
            "prompt": payload.get("prompt", ""),
            "error": "Request timed out",
            "error_details": {"type": "timeout"},
            "timestamp": time.time()
        }
    except Exception as e:
        elapsed = time.time() - start_time
        return {
            "request_id": request_id,
            "status": "error",
            "elapsed_time": elapsed,
            "prompt": payload.get("prompt", ""),
            "error": f"Unexpected error: {str(e)}",
            "error_details": {"type": "unexpected", "message": str(e), "exception_type": type(e).__name__},
            "timestamp": time.time()
        }


def get_ramp_up_function(pattern: str) -> Callable[[float, float], float]:
    """
    Returns a function that calculates the target concurrency at a given point in time.
    
    Args:
        pattern: The ramp-up pattern ('linear', 'exponential', or 'step')
        
    Returns:
        A function that takes (elapsed_time, total_ramp_up_time) and returns target concurrency percentage (0.0-1.0)
    """
    if pattern == 'linear':
        return lambda elapsed, total: min(1.0, elapsed / total) if total > 0 else 1.0
    
    elif pattern == 'exponential':
        # Starts slower, then accelerates
        return lambda elapsed, total: min(1.0, (elapsed / total) ** 2) if total > 0 else 1.0
    
    elif pattern == 'step':
        # 25%, 50%, 75%, 100% steps
        def step_function(elapsed, total):
            if total <= 0:
                return 1.0
            ratio = elapsed / total
            if ratio < 0.25:
                return 0.25
            elif ratio < 0.5:
                return 0.5
            elif ratio < 0.75:
                return 0.75
            else:
                return 1.0
        return step_function
    
    # Default to linear
    return lambda elapsed, total: min(1.0, elapsed / total) if total > 0 else 1.0


def print_progress_report(results, start_time, total_requests):
    """Print a progress report of the load test."""
    elapsed = time.time() - start_time
    successful = len([r for r in results if r.get("status") == 200])
    failed = len(results) - successful
    
    print(f"\n[Progress Report at {elapsed:.1f}s]")
    print(f"Requests completed: {len(results)}/{total_requests} ({len(results)/total_requests*100:.1f}%)")
    print(f"Successful: {successful}, Failed: {failed}")
    
    if successful > 0:
        elapsed_times = [r["elapsed_time"] for r in results if r.get("status") == 200]
        print(f"Avg response time: {sum(elapsed_times)/len(elapsed_times):.4f}s")
        print(f"Current rate: {len(results)/elapsed:.2f} req/sec")
    
    # Schedule the next report if not complete
    if len(results) < total_requests:
        threading.Timer(30.0, print_progress_report, [results, start_time, total_requests]).start()


async def run_load_test(concurrency: int, total_requests: int, url: str, payload_template: Dict[str, Any], 
                        vary_prompts: bool = True, ramp_up_time: float = 0, 
                        ramp_up_pattern: str = 'linear') -> List[Dict[str, Any]]:
    """Run a load test with the specified concurrency and ramp-up period."""
    results = []
    active_workers = 0
    worker_start_times = {}
    
    # Get the appropriate ramp-up function
    ramp_up_func = get_ramp_up_function(ramp_up_pattern)
    
    # Create a shared event to signal the start of the test
    start_event = asyncio.Event()
    
    # Create a shared event for each worker to signal when it can start
    worker_start_events = [asyncio.Event() for _ in range(concurrency)]
    
    # Track the test start time
    test_start_time = None
    
    # Start the progress reporting
    progress_reporter = threading.Timer(30.0, print_progress_report, [results, time.time(), total_requests])
    progress_reporter.daemon = True  # Allow the thread to exit when the main program exits
    
    async def worker_controller():
        """Controls the activation of workers according to the ramp-up pattern."""
        nonlocal active_workers, test_start_time
        
        # Set the test start time
        test_start_time = time.time()
        
        # Start the progress reporter
        progress_reporter.start()
        
        # Signal the start of the test
        start_event.set()
        
        # If no ramp-up time, activate all workers immediately
        if ramp_up_time <= 0:
            for event in worker_start_events:
                event.set()
            active_workers = concurrency
            return
        
        # Activate workers gradually according to the ramp-up pattern
        while active_workers < concurrency:
            elapsed_time = time.time() - test_start_time
            
            # If we've exceeded the ramp-up time, activate all remaining workers
            if elapsed_time >= ramp_up_time:
                for i in range(active_workers, concurrency):
                    worker_start_times[i] = time.time()
                    worker_start_events[i].set()
                active_workers = concurrency
                break
            
            # Calculate target number of active workers based on elapsed time
            target_active = math.ceil(concurrency * ramp_up_func(elapsed_time, ramp_up_time))
            
            # Activate new workers to reach the target
            while active_workers < target_active and active_workers < concurrency:
                worker_start_times[active_workers] = time.time()
                worker_start_events[active_workers].set()
                active_workers += 1
                print(f"Activated worker {active_workers}/{concurrency} at {elapsed_time:.2f}s")
            
            # Wait a short time before checking again
            await asyncio.sleep(0.1)
    
    async def worker(worker_id: int, queue: asyncio.Queue, results: List):
        # Wait for the test to start
        await start_event.wait()
        
        # Wait for this worker's activation signal
        await worker_start_events[worker_id].wait()
        
        # Create a single connector and session for this worker
        connector = aiohttp.TCPConnector(limit=0)  # No connection limit
        async with aiohttp.ClientSession(connector=connector) as session:
            while True:
                try:
                    request_id = await queue.get()
                    if request_id is None:
                        queue.task_done()
                        break
                    
                    # Create a payload copy with a potentially varied prompt
                    payload = payload_template.copy()
                    if vary_prompts:
                        payload["prompt"] = generate_random_prompt()
                    
                    # Use the worker's session for the request
                    result = await make_request(session, url, payload, request_id)
                    
                    # Add worker information to the result
                    result["worker_id"] = worker_id
                    result["worker_start_time"] = worker_start_times.get(worker_id, test_start_time)
                    
                    results.append(result)
                    queue.task_done()
                except Exception as e:
                    print(f"Worker {worker_id} error: {e}")
                    queue.task_done()
    
    # Create a queue and add tasks
    queue = asyncio.Queue()
    for i in range(total_requests):
        queue.put_nowait(i)
    
    # Add sentinel values to stop workers
    for _ in range(concurrency):
        queue.put_nowait(None)
    
    # Create worker tasks
    workers = [asyncio.create_task(worker(i, queue, results)) for i in range(concurrency)]
    
    # Create and start the worker controller
    controller = asyncio.create_task(worker_controller())
    
    # Wait for all tasks to complete
    await queue.join()
    
    # Wait for all workers to finish
    await asyncio.gather(*workers)
    
    # Wait for the controller to finish
    await controller
    
    # Cancel any pending progress reports
    progress_reporter.cancel()
    
    return results


def analyze_results(results: List[Dict[str, Any]], ramp_up_time: float = 0) -> Dict[str, Any]:
    """Analyze the results of the load test, separating ramp-up and full-load phases."""
    if not results:
        return {"error": "No results to analyze"}
    
    # Sort results by timestamp
    sorted_results = sorted(results, key=lambda r: r.get("timestamp", 0))
    
    # Find the earliest timestamp
    if sorted_results and "timestamp" in sorted_results[0]:
        test_start_time = min(r.get("timestamp", float('inf')) - r.get("elapsed_time", 0) for r in sorted_results)
    else:
        test_start_time = 0
    
    # Separate results into ramp-up and full-load phases
    ramp_up_results = []
    full_load_results = []
    
    for result in sorted_results:
        # Calculate when this request started relative to test start
        request_start_time = result.get("timestamp", 0) - result.get("elapsed_time", 0)
        relative_start_time = request_start_time - test_start_time
        
        if relative_start_time < ramp_up_time:
            ramp_up_results.append(result)
        else:
            full_load_results.append(result)
    
    # Analyze each phase
    phases = {
        "overall": analyze_phase(sorted_results),
        "ramp_up": analyze_phase(ramp_up_results) if ramp_up_time > 0 else None,
        "full_load": analyze_phase(full_load_results)
    }
    
    return phases


def analyze_phase(results: List[Dict[str, Any]]) -> Dict[str, Any]:
    """Analyze a specific phase of the load test."""
    if not results:
        return {"error": "No results to analyze"}
    
    successful_requests = [r for r in results if r.get("status") == 200]
    failed_requests = [r for r in results if r.get("status") != 200]
    
    # Categorize errors by type
    error_categories = {}
    for req in failed_requests:
        status = req.get("status")
        if isinstance(status, str):
            # Handle string status like "connection_error", "timeout", etc.
            error_type = status
        else:
            # Handle numeric HTTP status codes
            error_type = f"http_{status}"
        
        if error_type not in error_categories:
            error_categories[error_type] = []
        error_categories[error_type].append(req)
    
    elapsed_times = [r["elapsed_time"] for r in successful_requests]
    
    # Calculate time range for this phase
    if results and "timestamp" in results[0]:
        start_time = min(r.get("timestamp", float('inf')) - r.get("elapsed_time", 0) for r in results)
        end_time = max(r.get("timestamp", 0) for r in results)
        phase_duration = end_time - start_time
    else:
        phase_duration = sum(elapsed_times)
    
    return {
        "total_requests": len(results),
        "successful_requests": len(successful_requests),
        "failed_requests": len(failed_requests),
        "error_categories": error_categories,
        "avg_response_time": sum(elapsed_times) / len(elapsed_times) if elapsed_times else 0,
        "min_response_time": min(elapsed_times) if elapsed_times else 0,
        "max_response_time": max(elapsed_times) if elapsed_times else 0,
        "requests_per_second": len(successful_requests) / phase_duration if phase_duration > 0 else 0,
        "phase_duration": phase_duration
    }


async def main():
    parser = argparse.ArgumentParser(description="Load test for OpenAI API completions")
    parser.add_argument("--concurrency", type=int, default=10, help="Number of concurrent requests")
    parser.add_argument("--requests", type=int, default=25, help="Total number of requests to make")
    parser.add_argument("--model", type=str, default="tweet-summary", help="Model to use for completions")
    parser.add_argument("--prompt", type=str, help="Prompt to send to the API (if not provided, random prompts will be generated)")
    parser.add_argument("--vary-prompts", action="store_true", help="Generate different prompts for each request")
    parser.add_argument("--max-tokens", type=int, default=100, help="Maximum number of tokens to generate")
    parser.add_argument("--temperature", type=float, default=0.7, help="Temperature for sampling")
    parser.add_argument("--gateway-url", type=str, help="Override the gateway URL (format: http://<ip>:<port>)")
    parser.add_argument("--ramp-up-time", type=float, default=0, help="Time in seconds to gradually ramp up to full concurrency")
    parser.add_argument("--ramp-up-pattern", type=str, default="linear", choices=["linear", "exponential", "step"], 
                        help="Pattern for ramping up concurrency")
    args = parser.parse_args()
    
    if args.gateway_url:
        url = f"{args.gateway_url}/v1/completions"
    else:
        ip, port = await get_gateway_info()
        if not ip:
            print("Failed to get gateway information. Exiting.")
            return
        url = f"http://{ip}:{port}/v1/completions"
    
    # Determine if we should use random prompts
    use_random_prompts = args.prompt is None or args.vary_prompts
    
    # Create the base payload
    payload = {
        "model": args.model,
        "prompt": args.prompt if args.prompt else generate_random_prompt(),
        "max_tokens": args.max_tokens,
        "temperature": args.temperature
    }
    
    print(f"Starting load test with {args.concurrency} concurrent requests for a total of {args.requests} requests")
    if args.ramp_up_time > 0:
        print(f"Using {args.ramp_up_pattern} ramp-up over {args.ramp_up_time} seconds")
    print(f"Target URL: {url}")
    print(f"Base payload: {json.dumps(payload, indent=2)}")
    if use_random_prompts:
        print("Using randomly generated prompts for each request" if args.vary_prompts else "Using a randomly generated prompt")
    
    start_time = time.time()
    results = await run_load_test(
        args.concurrency, 
        args.requests, 
        url, 
        payload, 
        vary_prompts=use_random_prompts,
        ramp_up_time=args.ramp_up_time,
        ramp_up_pattern=args.ramp_up_pattern
    )
    total_time = time.time() - start_time
    
    analysis = analyze_results(results, args.ramp_up_time)
    
    print("\nLoad Test Results:")
    print(f"Total time: {total_time:.2f} seconds")
    
    # Print overall results
    overall = analysis["overall"]
    print("\nOVERALL STATISTICS:")
    print(f"Total requests: {overall['total_requests']}")
    print(f"Successful requests: {overall['successful_requests']}")
    print(f"Failed requests: {overall['failed_requests']}")
    print(f"Average response time: {overall['avg_response_time']:.4f} seconds")
    print(f"Min response time: {overall['min_response_time']:.4f} seconds")
    print(f"Max response time: {overall['max_response_time']:.4f} seconds")
    print(f"Requests per second: {overall['requests_per_second']:.2f}")
    
    # Print ramp-up phase results if applicable
    if args.ramp_up_time > 0 and analysis["ramp_up"]:
        ramp_up = analysis["ramp_up"]
        print("\nRAMP-UP PHASE STATISTICS:")
        print(f"Duration: {ramp_up['phase_duration']:.2f} seconds")
        print(f"Total requests: {ramp_up['total_requests']}")
        print(f"Successful requests: {ramp_up['successful_requests']}")
        print(f"Failed requests: {ramp_up['failed_requests']}")
        print(f"Average response time: {ramp_up['avg_response_time']:.4f} seconds")
        print(f"Requests per second: {ramp_up['requests_per_second']:.2f}")
    
    # Print full-load phase results
    full_load = analysis["full_load"]
    print("\nFULL-LOAD PHASE STATISTICS:")
    print(f"Duration: {full_load['phase_duration']:.2f} seconds")
    print(f"Total requests: {full_load['total_requests']}")
    print(f"Successful requests: {full_load['successful_requests']}")
    print(f"Failed requests: {full_load['failed_requests']}")
    print(f"Average response time: {full_load['avg_response_time']:.4f} seconds")
    print(f"Requests per second: {full_load['requests_per_second']:.2f}")
    
    # Display error information if there are any failed requests
    if overall['failed_requests'] > 0:
        print("\nError Summary:")
        for error_type, errors in overall['error_categories'].items():
            print(f"  {error_type}: {len(errors)} requests")
        
        print("\nDetailed Error Information:")
        for error_type, errors in overall['error_categories'].items():
            print(f"\n{error_type} ({len(errors)} occurrences):")
            # Show details for the first few errors of each type
            for i, error in enumerate(errors[:3]):
                print(f"  Example {i+1}:")
                if "error" in error:
                    print(f"    Error: {error['error']}")
                if "error_details" in error:
                    for k, v in error['error_details'].items():
                        # Truncate long values
                        if isinstance(v, str) and len(v) > 100:
                            v = v[:100] + "..."
                        elif isinstance(v, dict):
                            # For nested dictionaries, just show keys
                            v = f"Dict with keys: {list(v.keys())}"
                        print(f"    {k}: {v}")
            
            # If there are more errors of this type, indicate that
            if len(errors) > 3:
                print(f"    ... and {len(errors) - 3} more similar errors")
    
    # Optionally show some example prompts that were used
    if use_random_prompts and args.vary_prompts:
        print("\nExample prompts used:")
        sample_size = min(5, len(results))
        for i, result in enumerate(random.sample(results, sample_size)):
            print(f"Example {i+1}: {result.get('prompt', 'N/A')}")


if __name__ == "__main__":
    asyncio.run(main()) 