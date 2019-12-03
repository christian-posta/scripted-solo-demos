kubectl apply -f resources/gateway-v2-clean.yaml
kubectl delete virtualservice default -n gloo-system
cp ./resources/envoy_filter_http_wasm_example.cc.small.template ./project/envoy_filter_http_wasm_example.cc