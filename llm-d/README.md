
DIRECT:
python load_test.py --requests 50 --vary-prompts --gateway-url http://34.168.80.37:80 --concurrency 10 --model "meta-llama/Llama-3.2-3B-Instruct"

IGW:
python load_test.py --requests 50 --vary-prompts --gateway-url http://34.19.105.28:80 --concurrency 10 --model "meta-llama/Llama-3.2-3B-Instruct"