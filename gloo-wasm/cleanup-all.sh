kubectl delete ns istio-system gloo-system
kubectl delete -f resources/echo-server.yaml
kubectl delete -f resources/gloo-gateway-wasm.yaml
pushd project
bazel clean