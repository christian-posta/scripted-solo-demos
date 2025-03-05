#!/usr/bin/env python3
import asyncio
import aiohttp
import time
import math
import threading
import random
from typing import Dict, Any, List, Callable

from api_client import make_request
from analysis import generate_random_prompt


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
                        ramp_up_pattern: str = 'linear', token_info: Dict[str, int] = None) -> List[Dict[str, Any]]:
    """
    Run a load test with the specified concurrency and ramp-up period.
    
    Args:
        concurrency: Number of concurrent workers
        total_requests: Total number of requests to make
        url: Target URL for requests
        payload_template: Template for request payload
        vary_prompts: Whether to generate different prompts for each request
        ramp_up_time: Time in seconds to gradually ramp up to full concurrency
        ramp_up_pattern: Pattern for ramping up concurrency
        token_info: Dictionary with token size configuration
    
    Returns:
        List of results from all requests
    """
    # Use default token info if not provided
    if token_info is None:
        token_info = {
            "input_tokens_mean": 550,
            "input_tokens_stddev": 200,
            "output_tokens_mean": 150,
            "output_tokens_stddev": 10
        }
    
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
                    
                    # Create a payload copy with a potentially varied prompt and max_tokens
                    payload = payload_template.copy()
                    if vary_prompts:
                        payload["prompt"] = generate_random_prompt(
                            target_tokens=token_info["input_tokens_mean"],
                            tokens_stddev=token_info["input_tokens_stddev"]
                        )
                    
                    # Vary the max_tokens parameter based on the configured mean and stddev
                    payload["max_tokens"] = max(1, int(random.gauss(
                        token_info["output_tokens_mean"],
                        token_info["output_tokens_stddev"]
                    )))
                    
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