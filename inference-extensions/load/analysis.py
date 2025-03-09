#!/usr/bin/env python3
import random
from faker import Faker
from typing import Dict, Any, List
import math
import os
import sys

# Try different import approaches to handle running from different directories
try:
    # When running from within the load directory
    from templates.placeholder_values import placeholder_values
except ImportError:
    try:
        # When running from the parent directory
        from load.templates.placeholder_values import placeholder_values
    except ImportError:
        # If all else fails, try to add the directory to the path
        sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
        from load.templates.placeholder_values import placeholder_values


def estimate_token_count(text: str) -> int:
    """
    Estimate the number of tokens in a text string.
    This is a rough approximation: ~4 characters per token for English text.
    """
    return max(1, len(text) // 4)


def generate_coherent_prompt(template_name: str, placeholders: Dict[str, str]) -> str:
    """
    Generate a coherent prompt using a specified template and placeholder values.
    
    Args:
        template_name: The name of the template to use
        placeholders: A dictionary of placeholder values to fill in the template
    
    Returns:
        A string with the placeholders filled in
    """
    # Determine the category from the template name
    # The placeholder_values dictionary has keys like "market_analysis" which correspond to
    # templates in specific category folders (e.g., business/market_analysis.txt)
    
    # Map template names to their categories
    template_categories = {
        # Business templates
        "market_analysis": "business",
        "product_launch": "business",
        
        # Technical templates
        "code_review": "technical",
        "system_design": "technical",
        
        # Academic templates
        "research_proposal": "academic",
        
        # Creative templates
        "story_outline": "creative"
    }
    
    category = template_categories.get(template_name, "")
    
    # Load the template file from the appropriate category directory
    template_path = f"templates/{category}/{template_name}.txt"
    try:
        with open(template_path, "r") as template_file:
            template_content = template_file.read()
    except FileNotFoundError:
        # Try with the load/ prefix if running from a different directory
        template_path = f"load/templates/{category}/{template_name}.txt"
        with open(template_path, "r") as template_file:
            template_content = template_file.read()
    
    # Replace placeholders in the template
    for key, value in placeholders.items():
        # Ensure the placeholder format matches the template
        template_content = template_content.replace(f"{{{key}}}", value)
    
    return template_content


def generate_random_prompt(target_tokens: int = 550, tokens_stddev: int = 200) -> str:
    """
    Generate a random prompt with a target token count.
    
    Args:
        target_tokens: Target number of tokens for the prompt
        tokens_stddev: Standard deviation for token count variation
    
    Returns:
        A prompt with approximately the target number of tokens
    """
    # Select a random template and corresponding placeholder values
    template_name = random.choice(list(placeholder_values.keys()))
    placeholders = placeholder_values[template_name]
    
    # Generate a coherent prompt using the selected template and placeholders
    prompt = generate_coherent_prompt(template_name, placeholders)
    
    # Estimate the token count and adjust if necessary
    current_tokens = estimate_token_count(prompt)
    actual_target = max(10, int(random.gauss(target_tokens, tokens_stddev)))
    
    # Add additional content if needed to reach the target token count
    while current_tokens < actual_target:
        additional_content = f" {random.choice(['Also', 'Additionally', 'Furthermore', 'Moreover'])}, {Faker().bs()}."
        prompt += additional_content
        current_tokens = estimate_token_count(prompt)
    
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
    
    # Add model-specific analysis
    models_used = set(r.get("model", "unknown") for r in sorted_results)
    phases["per_model"] = {model: analyze_phase([r for r in sorted_results if r.get("model") == model]) 
                          for model in models_used}
    
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