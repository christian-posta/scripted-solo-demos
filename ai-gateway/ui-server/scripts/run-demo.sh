#!/bin/bash

# Check if demo name is provided
if [ -z "$1" ]; then
    echo "Please provide a demo name as an argument"
    exit 1
fi

# Get the demo name from argument
DEMO_NAME=$1

# Get scripts root dir from env var, default to current directory
DEMO_DIR=/home/solo/scripted-solo-demos/ai-gateway

# Function to run commands for demo
run_demo() {
    case $1 in
        "01-demo-hidecred")
            pushd $DEMO_DIR
            ./reset-demo.sh --for 1 > /dev/null 2>&1
            ./kubectl_finder.py "01-demo-hidecred.sh" --run 0 -y
            popd
            ;;
        "02-demo-mngcred")
            pushd $DEMO_DIR
            ./reset-demo.sh --for 2 > /dev/null 2>&1
            ./kubectl_finder.py "02-demo-mngcred.sh" --run 0 -y
            popd
            ;;
        "03-demo-ratelimit")
            pushd $DEMO_DIR
            ./reset-demo.sh --for 3 > /dev/null 2>&1
            ./kubectl_finder.py "03-demo-ratelimit.sh" --run 0 -y
            popd
            ;;
        "04-demo-model-failover")
            pushd $DEMO_DIR
            ./reset-demo.sh --for 4 > /dev/null 2>&1
            ./kubectl_finder.py "04-demo-model-failover.sh" --run 0 -y
            popd
            ;;
        "05-demo-prompt-guard-reject")
            pushd $DEMO_DIR
            ./reset-demo.sh --for 5 > /dev/null 2>&1
            ./kubectl_finder.py "05-a-prompt-guard.sh" --run 0 -y
            popd
            ;;
        "05-demo-prompt-guard-mask")
            pushd $DEMO_DIR
            ./reset-demo.sh --for 5 > /dev/null 2>&1
            ./kubectl_finder.py "05-a-prompt-guard.sh" --run 1 -y
            popd
            ;;
        "05-demo-prompt-guard-moderation")
            pushd $DEMO_DIR
            ./reset-demo.sh --for 5 > /dev/null 2>&1
            ./kubectl_finder.py "05-a-prompt-guard.sh" --run 2 -y
            popd
            ;;
        "05-demo-prompt-guard-custom")
            pushd $DEMO_DIR
            ./reset-demo.sh --for 5 > /dev/null 2>&1
            ./kubectl_finder.py "05-b-prompt-guard.sh" --run 0 -y
            popd
            ;;
        "06-demo-semantic-cache")
            pushd $DEMO_DIR
            ./reset-demo.sh --for 6 > /dev/null 2>&1
            ./kubectl_finder.py "06-semantic-cache.sh" --run 0 -y
            popd
            ;;
        "07-demo-rag")
            pushd $DEMO_DIR
            ./reset-demo.sh --for 7 > /dev/null 2>&1
            ./kubectl_finder.py "07-rag.sh" --run 0 -y
            popd
            ;;
        "08-demo-traffic-shift")
            pushd $DEMO_DIR
            ./reset-demo.sh --for 8 > /dev/null 2>&1
            ./kubectl_finder.py "08-traffic-shift.sh" --run 0 -y
            popd
            ;;
        *)
            echo "Invalid demo name: $1"
            exit 1
            ;;
    esac
}

# Run the demo
run_demo "$DEMO_NAME" 