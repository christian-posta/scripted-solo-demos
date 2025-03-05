#!/usr/bin/env python3
import random
from faker import Faker
from typing import Dict, Any, List


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