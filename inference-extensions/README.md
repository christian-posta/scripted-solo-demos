To run this demo, make sure you have a cluster with GPU nodes

Run the following to set up the env:

```bash
./setup.sh
```

Then from another window, start a load test:

```bash
python load_test.py --requests 50 --vary-prompts --gateway-url http://$DIRECT_ENDPOINT --concurrency 10 --model "tweet-summary-0,tweet-summary-1"
```

```bash
python load_test.py --requests 50 --vary-prompts --gateway-url http://$IGW_ENDPOINT --concurrency 10
```

You can then portforward grafana to port 3000 and review the LLM Dashboard.

