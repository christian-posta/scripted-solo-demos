
kubectl apply -f resources/echo-server.yaml

# Install gloo with wasm support:
# check it like this:
# glooctl install gateway -n gloo-system --values <(echo '{"namespace":{"create":true},"crds":{"create":true},"global":{"wasm":{"enabled":true}}}') --dry-run

kubectl create ns gloo-system
kubectl apply -f resources/gloo-gateway-wasm.yaml

echo "You should delete all of the tags in the registry for these modules: filter-demo:*.*"
