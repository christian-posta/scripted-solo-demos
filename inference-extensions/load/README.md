# API Load Testing Tool

This tool allows you to perform load testing against an OpenAI-compatible API endpoint by sending concurrent requests.

## Prerequisites

- Python 3.7+
- kubectl configured to access your Kubernetes cluster with the inference-gateway
- Required Python packages (install using `pip install -r requirements.txt`)

## Installation

1. Clone this repository or download the files
2. Install the required dependencies:

```bash
pip install -r requirements.txt
```

## Usage

Run the load test with default parameters:

```bash
python load_test.py
```

Run with specific params

```bash
python load_test.py --requests 100 --vary-prompts
```

Or a specific gateway:

```bash

# Direct to vLLM; note to LB across Lora models
# note replace localhost with actual HOST/IP
python load_test.py --requests 50 --vary-prompts --gateway-url http://localhost:8000 --concurrency 10 --model "tweet-summary-0,tweet-summary-1"

# Through GW
python load_test.py --requests 50 --vary-prompts --gateway-url http://localhost:8080 --concurrency 10 
```

### Command Line Arguments

- `--concurrency`: Number of concurrent requests (default: 10)
- `--requests`: Total number of requests to make (default: 25)
- `--model`: Model(s) to use for completions (comma-delimited for multiple models, default: "tweet-summary")
- `--prompt`: Prompt to send to the API (default: "Write as if you were a critic: San Francisco")
- `--max-tokens`: Maximum number of tokens to generate (default: 100)
- `--temperature`: Temperature for sampling (default: 0)
- `--vary-prompts`: If a prompt is not specified, then generate some automatically
- `--gateway-url`: The specific gateway url to call, defaults to figuring out automatically
- `--ramp-up-time`: Time in seconds to gradually ramp up to full concurrency (default: 0)
- `--ramp-up-pattern`: Pattern for ramping up concurrency. Options are `linear`, `exponential`, or `step` (default: `linear`).
- `--input-tokens-mean`: default 550
- `--input-tokens-stddev`: default 200
- `--output-tokens-mean`: default 150
- `--output-tokens-stddev`: default 10
- `--show-prompts-used`: Show some of the example prompts used at the end of the runs
- `--model-selection`: Strategy for selecting models when multiple are provided. Options are `round-robin` or `random` (default: `round-robin`)

### Examples

Run 50 requests with 20 concurrent connections:
(recommended to use ramp-up time to not slam the backends right off the bat)

```bash
python load_test.py --requests 100 --vary-prompts --gateway-url http://$IP:$PORT --concurrency 50 --ramp-up-time 30

```

Use a different model and prompt:

```bash
python load_test.py --model "different-model" --prompt "Describe the weather in New York"
```

Run with multiple models using round-robin selection:
```bash
python load_test.py --model "model1,model2,model3" --model-selection round-robin
```

Run with multiple models using random selection:
```bash
python load_test.py --model "model1,model2,model3" --model-selection random
```

## Output

The script will output:
- Total time taken for all requests
- Number of successful and failed requests
- Average, minimum, and maximum response times
- Requests per second

## Notes

- The script automatically retrieves the gateway IP from your Kubernetes cluster
- Ensure your kubectl context is set correctly before running the script