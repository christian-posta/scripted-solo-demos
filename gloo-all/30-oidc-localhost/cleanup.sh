
kubectl delete -f dex.yaml -n gloo-system
kubectl delete secret -n gloo-system $(k get secret -n gloo-system | grep dex | awk '{print $1}' )
kubectl delete -n gloo-system cm $(k get cm -n gloo-system | grep dex | awk '{print $1}')