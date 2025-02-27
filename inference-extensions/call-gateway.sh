IP=$(kubectl get gateway/inference-gateway -o jsonpath='{.status.addresses[0].value}')
PORT=8081

curl -v ${IP}:${PORT}/v1/completions -H 'Content-Type: application/json' -d '{
"model": "tweet-summary",
"prompt": "Write as if you were a critic: San Francisco",
"max_tokens": 100,
"temperature": 0
}'

