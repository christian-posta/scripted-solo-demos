#!/bin/bash
# Continuous variable load testing for Istio Bookinfo using Fortio
# This script runs indefinitely with varying load patterns

# Configuration
GATEWAY_URL=${GATEWAY_URL:-"http://localhost:8080"}
PRODUCTPAGE_PATH=${PRODUCTPAGE_PATH:-"/productpage"}
BASE_URL="$GATEWAY_URL$PRODUCTPAGE_PATH"
LOG_DIR=${LOG_DIR:-"./fortio-logs"}

# Create log directory
mkdir -p "$LOG_DIR"

# Array of endpoints to test
declare -a ENDPOINTS=(
    "$BASE_URL"
    "$BASE_URL?u=normal"
    "$BASE_URL?u=test"
    "$GATEWAY_URL/api/v1/products"
    "$GATEWAY_URL/api/v1/products/0"
    "$GATEWAY_URL/api/v1/reviews/0"
    "$GATEWAY_URL/api/v1/ratings/0"
)

# Function to run load test with specific parameters
run_load_pattern() {
    local qps=$1
    local duration=$2
    local connections=$3
    local pattern_name=$4
    
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Starting $pattern_name pattern (QPS: $qps, Duration: ${duration}s, Connections: $connections)"
    
    # Calculate QPS per endpoint (divide total desired QPS by number of endpoints)
    local endpoint_qps=$(echo "scale=2; $qps / ${#ENDPOINTS[@]}" | bc)
    
    # Run Fortio load test for each endpoint
    for endpoint in "${ENDPOINTS[@]}"; do
        echo "Testing endpoint: $endpoint"
        fortio load -qps "$endpoint_qps" -t "${duration}s" -c "$connections" "$endpoint" | grep -E "Code|Longest|50th|99th|Qps"
        echo "----"
    done
    
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Completed $pattern_name pattern"
    echo "------------------------------------"
}

# Function to follow a daily traffic pattern
simulate_daily_pattern() {
    # Morning ramp-up (8AM-11AM)
    run_load_pattern 5 300 2 "Early morning - Light"
    run_load_pattern 15 300 4 "Morning - Medium"
    
    # Midday peak (11AM-2PM)
    run_load_pattern 30 300 8 "Midday - Heavy"
    
    # Afternoon steady (2PM-5PM)
    run_load_pattern 20 300 6 "Afternoon - Medium-Heavy"
    
    # Evening decline (5PM-8PM)
    run_load_pattern 12 300 4 "Evening - Medium"
    
    # Night minimal (8PM-8AM)
    run_load_pattern 3 600 2 "Night - Light"
}

# Function to simulate random spikes in traffic
simulate_random_spikes() {
    # Base load
    local base_qps=$(( RANDOM % 5 + 3 ))  # Random 3-8 QPS
    local base_conn=$(( RANDOM % 3 + 2 )) # Random 2-4 connections
    
    # Random chance of spike (1 in 4)
    if [ $(( RANDOM % 4 )) -eq 0 ]; then
        # Spike load
        local spike_qps=$(( RANDOM % 20 + 20 ))  # Random 20-40 QPS
        local spike_conn=$(( RANDOM % 4 + 6 ))   # Random 6-10 connections
        run_load_pattern "$spike_qps" 120 "$spike_conn" "Traffic spike"
    else
        # Regular load
        run_load_pattern "$base_qps" 180 "$base_conn" "Regular traffic"
    fi
}

# Function to run weekend pattern (different from weekday)
simulate_weekend_pattern() {
    # Lighter morning
    run_load_pattern 3 600 2 "Weekend morning - Very light"
    
    # Midday moderate
    run_load_pattern 10 600 3 "Weekend midday - Light"
    
    # Evening peak (different from weekday pattern)
    run_load_pattern 25 300 6 "Weekend evening - Medium-Heavy"
    
    # Late night decline
    run_load_pattern 5 600 2 "Weekend night - Light"
}

# Main loop - run continuously
echo "Starting continuous variable load testing at $(date)"
echo "Gateway URL: $GATEWAY_URL"
echo "Press Ctrl+C to stop the test"
echo "------------------------------------"

# Trap Ctrl+C to clean up
trap "echo 'Test stopped by user at $(date)'; exit 0" INT

# Continuous execution loop
while true; do
    # Check if it's weekend (Saturday=6, Sunday=0)
    day_of_week=$(date +%u)
    if [ "$day_of_week" -eq 6 ] || [ "$day_of_week" -eq 7 ]; then
        # Weekend pattern
        simulate_weekend_pattern
    else
        # Get current hour to determine which pattern to run
        hour=$(date +%H)
        if [ "$hour" -ge 8 ] && [ "$hour" -lt 20 ]; then
            # Daytime - follow regular daily pattern
            simulate_daily_pattern
        else
            # Nighttime - random pattern with occasional spikes
            simulate_random_spikes
        fi
    fi
    
    # Small sleep between test sets to avoid any potential resource issues
    sleep 5
done
