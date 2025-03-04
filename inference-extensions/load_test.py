#!/usr/bin/env python3
import argparse
import asyncio
import aiohttp
import time
import json
import subprocess
import random
from faker import Faker
from typing import Dict, Any, List


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
            response_data = await response.json()
            status = response.status
            elapsed = time.time() - start_time
            return {
                "request_id": request_id,
                "status": status,
                "elapsed_time": elapsed,
                "prompt": payload.get("prompt", ""),
                "response": response_data
            }
    except Exception as e:
        elapsed = time.time() - start_time
        return {
            "request_id": request_id,
            "status": "error",
            "elapsed_time": elapsed,
            "prompt": payload.get("prompt", ""),
            "error": str(e)
        }


async def run_load_test(concurrency: int, total_requests: int, url: str, payload_template: Dict[str, Any], 
                        vary_prompts: bool = True) -> List[Dict[str, Any]]:
    """Run a load test with the specified concurrency."""
    results = []
    
    async def worker(worker_id: int, queue: asyncio.Queue, results: List):
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
                
                # Create a new session for each request
                async with aiohttp.ClientSession() as session:
                    result = await make_request(session, url, payload, request_id)
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
    
    # Wait for all tasks to complete
    await queue.join()
    
    # Wait for all workers to finish
    await asyncio.gather(*workers)
    
    return results


def analyze_results(results: List[Dict[str, Any]]) -> Dict[str, Any]:
    """Analyze the results of the load test."""
    if not results:
        return {"error": "No results to analyze"}
    
    successful_requests = [r for r in results if r.get("status") == 200]
    failed_requests = [r for r in results if r.get("status") != 200]
    
    elapsed_times = [r["elapsed_time"] for r in successful_requests]
    
    return {
        "total_requests": len(results),
        "successful_requests": len(successful_requests),
        "failed_requests": len(failed_requests),
        "avg_response_time": sum(elapsed_times) / len(elapsed_times) if elapsed_times else 0,
        "min_response_time": min(elapsed_times) if elapsed_times else 0,
        "max_response_time": max(elapsed_times) if elapsed_times else 0,
        "requests_per_second": len(successful_requests) / sum(elapsed_times) if elapsed_times else 0
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
    print(f"Target URL: {url}")
    print(f"Base payload: {json.dumps(payload, indent=2)}")
    if use_random_prompts:
        print("Using randomly generated prompts for each request" if args.vary_prompts else "Using a randomly generated prompt")
    
    start_time = time.time()
    results = await run_load_test(args.concurrency, args.requests, url, payload, vary_prompts=use_random_prompts)
    total_time = time.time() - start_time
    
    analysis = analyze_results(results)
    
    print("\nLoad Test Results:")
    print(f"Total time: {total_time:.2f} seconds")
    print(f"Total requests: {analysis['total_requests']}")
    print(f"Successful requests: {analysis['successful_requests']}")
    print(f"Failed requests: {analysis['failed_requests']}")
    print(f"Average response time: {analysis['avg_response_time']:.4f} seconds")
    print(f"Min response time: {analysis['min_response_time']:.4f} seconds")
    print(f"Max response time: {analysis['max_response_time']:.4f} seconds")
    print(f"Requests per second: {analysis['requests_per_second']:.2f}")
    
    # Optionally show some example prompts that were used
    if use_random_prompts and args.vary_prompts:
        print("\nExample prompts used:")
        sample_size = min(5, len(results))
        for i, result in enumerate(random.sample(results, sample_size)):
            print(f"Example {i+1}: {result.get('prompt', 'N/A')}")


if __name__ == "__main__":
    asyncio.run(main()) 