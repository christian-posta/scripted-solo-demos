# delete consul
kubectl delete -f resources/consul-1.6.2.yaml
kubectl delete -f resources/default-vs.yaml
kubectl delete upstream consul -n gloo-system
kubectl delete upstream jsonplaceholder -n gloo-system