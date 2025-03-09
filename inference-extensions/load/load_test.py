#!/usr/bin/env python3
import argparse
import asyncio
import time
import json
import random

# Import from our new modules
from api_client import get_gateway_info
from analysis import generate_random_prompt, analyze_results
from test_runner import run_load_test


async def main():
    parser = argparse.ArgumentParser(description="Load test for OpenAI API completions")
    parser.add_argument("--concurrency", type=int, default=10, help="Number of concurrent requests")
    parser.add_argument("--requests", type=int, default=25, help="Total number of requests to make")
    parser.add_argument("--model", type=str, default="tweet-summary", 
                        help="Model(s) to use for completions (comma-delimited for multiple models)")
    parser.add_argument("--model-selection", type=str, default="round-robin", 
                        choices=["round-robin", "random"], 
                        help="Model selection strategy when multiple models are provided")
    parser.add_argument("--prompt", type=str, help="Prompt to send to the API (if not provided, random prompts will be generated)")
    parser.add_argument("--vary-prompts", action="store_true", help="Generate different prompts for each request")
    parser.add_argument("--max-tokens", type=int, default=100, help="Maximum number of tokens to generate")
    parser.add_argument("--temperature", type=float, default=0.7, help="Temperature for sampling")
    parser.add_argument("--gateway-url", type=str, help="Override the gateway URL (format: http://<ip>:<port>)")
    parser.add_argument("--ramp-up-time", type=float, default=0, help="Time in seconds to gradually ramp up to full concurrency")
    parser.add_argument("--ramp-up-pattern", type=str, default="linear", choices=["linear", "exponential", "step"], 
                        help="Pattern for ramping up concurrency")
    # Add new arguments for token size control
    parser.add_argument("--input-tokens-mean", type=int, default=550, 
                        help="Mean number of tokens for input prompts (default: 550)")
    parser.add_argument("--input-tokens-stddev", type=int, default=200, 
                        help="Standard deviation of tokens for input prompts (default: 200)")
    parser.add_argument("--output-tokens-mean", type=int, default=150, 
                        help="Mean number of tokens for output generation (default: 150)")
    parser.add_argument("--output-tokens-stddev", type=int, default=10, 
                        help="Standard deviation of tokens for output generation (default: 10)")
    parser.add_argument("--show-prompts-used", action="store_true", help="Display example prompts used during the load test")
    args = parser.parse_args()
    
    if args.gateway_url:
        url = f"{args.gateway_url}/v1/completions"
    else:
        ip, port = await get_gateway_info()
        if not ip:
            print("Failed to get gateway information. Exiting.")
            return
        url = f"http://{ip}:{port}/v1/completions"
    
    # Parse the model parameter into a list
    models = [model.strip() for model in args.model.split(",")]
    print(f"Using {len(models)} model(s): {', '.join(models)}")
    print(f"Model selection strategy: {args.model_selection}")
    
    # Determine if we should use random prompts
    use_random_prompts = args.prompt is None or args.vary_prompts
    
    # Create the base payload
    payload = {
        "model": models[0],  # Default to first model, will be replaced per request
        "prompt": args.prompt if args.prompt else generate_random_prompt(
            target_tokens=args.input_tokens_mean, 
            tokens_stddev=args.input_tokens_stddev
        ),
        "max_tokens": max(1, int(random.gauss(args.output_tokens_mean, args.output_tokens_stddev))),
        "temperature": args.temperature
    }
    
    # Token size information for the test
    token_info = {
        "input_tokens_mean": args.input_tokens_mean,
        "input_tokens_stddev": args.input_tokens_stddev,
        "output_tokens_mean": args.output_tokens_mean,
        "output_tokens_stddev": args.output_tokens_stddev
    }
    
    print(f"Starting load test with {args.concurrency} concurrent requests for a total of {args.requests} requests")
    if args.ramp_up_time > 0:
        print(f"Using {args.ramp_up_pattern} ramp-up over {args.ramp_up_time} seconds")
    print(f"Target URL: {url}")
    print(f"Base payload: {json.dumps(payload, indent=2)}")
    print(f"Token size configuration:")
    print(f"  Input tokens: mean={args.input_tokens_mean}, stddev={args.input_tokens_stddev}")
    print(f"  Output tokens: mean={args.output_tokens_mean}, stddev={args.output_tokens_stddev}")
    if use_random_prompts:
        print("Using randomly generated but coherent prompts for each request" if args.vary_prompts else "Using user prompt form the parameters.")
    
    should_continue = input("Should continue Y/n? ").strip().lower() or 'y'
    if should_continue not in ['y', 'yes']:
        print("Exiting the load test.")
        return
    
    start_time = time.time()
    results = await run_load_test(
        args.concurrency, 
        args.requests, 
        url, 
        payload, 
        vary_prompts=use_random_prompts,
        ramp_up_time=args.ramp_up_time,
        ramp_up_pattern=args.ramp_up_pattern,
        token_info=token_info,
        models=models,
        model_selection=args.model_selection
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
    if use_random_prompts and args.vary_prompts and args.show_prompts_used:
        print("\nExample prompts used:")
        sample_size = min(5, len(results))
        for i, result in enumerate(random.sample(results, sample_size)):
            print(f"Example {i+1}: {result.get('prompt', 'N/A')}")

    # Print model-specific results
    if "per_model" in analysis:
        print("\nPER-MODEL STATISTICS:")
        for model, model_stats in analysis["per_model"].items():
            print(f"\nModel: {model}")
            print(f"  Total requests: {model_stats['total_requests']}")
            print(f"  Successful requests: {model_stats['successful_requests']}")
            print(f"  Failed requests: {model_stats['failed_requests']}")
            print(f"  Average response time: {model_stats['avg_response_time']:.4f} seconds")
            print(f"  Min response time: {model_stats['min_response_time']:.4f} seconds")
            print(f"  Max response time: {model_stats['max_response_time']:.4f} seconds")


if __name__ == "__main__":
    asyncio.run(main()) 