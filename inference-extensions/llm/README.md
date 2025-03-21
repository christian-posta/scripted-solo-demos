If you want to expose the vllm directly to be load balanced run the following:

> kubectl expose deploy/my-pool --name my-pool-lb --port=8000 --target-port=8000 --type=LoadBalancer

