VERSION=2.1.0-main
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/standard-install.yaml
helm upgrade -i kgateway-crds oci://cr.kgateway.dev/kgateway-dev/charts/kgateway-crds --version $VERSION --namespace kgateway-system --create-namespace
helm upgrade -i --namespace kgateway-system --version $VERSION kgateway oci://cr.kgateway.dev/kgateway-dev/charts/kgateway \
--set agentGateway.enabled=true \
--set agentGateway.enableAlphaAPIs=true