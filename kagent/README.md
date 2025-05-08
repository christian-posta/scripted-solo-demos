Notes to set up this demo.

run the following to bootstrap the cluster:

> ./setup-all.sh

Make sure you port forward the following services:

kiali 20001
kagent ui 8082
argo rollouts ui 3100
istio ingress /product page 8080


to update the image for the rollouts use the following command:

for v2
> docker.io/istio/examples-bookinfo-reviews-v2:1.17.0
> kubectl set image deployment/reviews reviews=docker.io/istio/examples-bookinfo-reviews-v2:1.17.0 -n bookinfo-backends

for v3
> docker.io/istio/examples-bookinfo-reviews-v3:1.17.0
> kubectl set image deployment/reviews reviews=docker.io/istio/examples-bookinfo-reviews-v3:1.17.0 -n bookinfo-backends


## How to Demo A2A

All agents are exposed on:

```bash
https://kagent.kagent.svc.cluster.local:8083/api/a2a/kagent/<agent_name>/
```

For example, for the built-in `k8s-agent`:

```bash
https://kagent.kagent.svc.cluster.local:8083/api/a2a/kagent/k8s-agent/.well-known/agent.json
```

If you portforward:

```bash
kubectl port-forward svc/kagent 8083:8083 -n kagent

curl http://localhost:8083/api/a2a/kagent/k8s-agent/.well-known/agent.json
```

Go to the A2A demo in `A2A/samples/python/hosts/cli`
```bash
uv run . --agent http://127.0.0.1:8083/api/a2a/kagent/k8s-agent
```

