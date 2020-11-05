kubectl label namespace default istio-injection-
glooctl istio uninject
kubectl delete upstream -n gloo-system default-web-api-8080
kubectl delete -f default-peerauth-strict.yaml