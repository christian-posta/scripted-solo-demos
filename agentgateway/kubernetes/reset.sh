kubectl delete -f mcp.yaml
kubectl delete -f gateway.yaml
kubectl delete -f httproute.yaml
kubectl delete -f a2a.yaml
kubectl delete -f a2a-httproute.yaml

kubectl delete -f static/gateway.yaml
kubectl delete -f static/agw-cm.yaml
