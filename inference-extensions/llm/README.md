If you want to expose the vllm directly to be load balanced run the following:

> kubectl expose deploy/vllm-llama2-7b --name vllm-llama2-7b-lb --port=80 --target-port=8000 --type=LoadBalancer

