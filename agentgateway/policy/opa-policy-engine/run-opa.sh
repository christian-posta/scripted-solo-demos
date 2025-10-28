docker run -it \
  --name opa-policy-engine \
  --rm \
  -p 8181:8181 \
  -p 9191:9191 \
  -v $(pwd)/policies:/policies \
  -v $(pwd)/config:/config \
  -e OPA_LOG_LEVEL=info \
  openpolicyagent/opa:1.9.0-envoy-6-static \
  run --server --addr=0.0.0.0:8181 --config-file=/config/opa-config.yaml /policies
