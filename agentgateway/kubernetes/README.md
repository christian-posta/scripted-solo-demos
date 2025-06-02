
Make sure you are running on a kubernetes cluster. You can just spin up a local kind cluster if you want, eg:

```bash
kind create cluster --name kagent
```

Install gateway (from main at the moment):
https://github.com/kgateway-dev/kgateway/releases


```bash
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.1/standard-install.yaml
helm upgrade -i kgateway-crds oci://cr.kgateway.dev/kgateway-dev/charts/kgateway-crds --version v2.1.0-main --namespace kgateway-system --create-namespace
helm upgrade -i kgateway oci://cr.kgateway.dev/kgateway-dev/charts/kgateway --version v2.1.0-main --namespace kgateway-system --create-namespace --set agentGateway.enabled=true  --set image.registry=ghcr.io/kgateway-dev
```

Deploy remote mcp server:

```bash
kubectl apply -f kubernetes/mcp.yaml
kubectl apply -f kubernetes/gateway.yaml
```

Can port forward for the UI:
```bash
AGW=$(kubectl get pods -l gateway.networking.k8s.io/gateway-name=agent-gateway -o jsonpath='{.items[0].metadata.name}')
kubectl port-forward $AGW 19000:19000
```

You will also need to expose the listener endpoint from the agw:

```bash
AGW=$(kubectl get pods -l gateway.networking.k8s.io/gateway-name=agent-gateway -o jsonpath='{.items[0].metadata.name}')
kubectl port-forward $AGW 8080:8080
```



Uninstall:

```bash
kubectl delete -f kubernetes/mcp.yaml
kubectl delete -f kubernetes/gateway.yaml

helm uninstall -n kgateway-system kgateway
helm uninstall -n kgateway-system kgateway-crds
```
