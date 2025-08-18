
Make sure you are running on a kubernetes cluster. You can just spin up a local kind cluster if you want, eg:

```bash
kind create cluster --name kagent
```

Install gateway (from main at the moment):
https://github.com/kgateway-dev/kgateway/releases


```bash
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/standard-install.yaml
helm upgrade -i kgateway-crds oci://cr.kgateway.dev/kgateway-dev/charts/kgateway-crds --version v2.1.0-main --namespace kgateway-system --create-namespace
helm upgrade -i --namespace kgateway-system --version v2.1.0-main kgateway oci://cr.kgateway.dev/kgateway-dev/charts/kgateway \
--set agentGateway.enabled=true \
--set agentGateway.enableAlphaAPIs=true

```

Deploy remote mcp server:

```bash
kubectl apply -f kubernetes/mcp.yaml
kubectl apply -f kubernetes/gateway.yaml
kubectl apply -f kubernetes/httproute.yaml
```

Can port forward for the UI:
```bash
AGW=$(kubectl get pods -l gateway.networking.k8s.io/gateway-name=agentgateway -o jsonpath='{.items[0].metadata.name}')
kubectl port-forward $AGW 15000:15000
```

You will also need to expose the listener endpoint from the agw:

```bash
AGW=$(kubectl get pods -l gateway.networking.k8s.io/gateway-name=agentgateway -o jsonpath='{.items[0].metadata.name}')
kubectl port-forward $AGW 8085:8080
```



Uninstall:

```bash
kubectl delete -f kubernetes/mcp.yaml


helm uninstall -n kgateway-system kgateway
helm uninstall -n kgateway-system kgateway-crds
```
