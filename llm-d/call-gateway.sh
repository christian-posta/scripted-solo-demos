IP=$(kubectl get gateway/llm-d-inference-gateway -o jsonpath='{.status.addresses[0].value}')
PORT=80

echo "IP: ${IP}"
echo "PORT: ${PORT}"

if [ "$1" == "load" ]; then
  for i in {1..25}; do
    curl -i ${IP}:${PORT}/v1/completions -H 'Content-Type: application/json' -d '{
      "model": "meta-llama/Llama-3.2-3B-Instruct",
      "prompt": "Write as if you were a critic: San Francisco",
      "max_tokens": 100,
      "temperature": 0
    }'
  done
else
  curl -i ${IP}:${PORT}/v1/completions -H 'Content-Type: application/json' -d '{
    "model": "meta-llama/Llama-3.2-3B-Instruct",
    "prompt": "Write as if you were a critic: San Francisco",
    "max_tokens": 100,
    "temperature": 0
  }'
fi
