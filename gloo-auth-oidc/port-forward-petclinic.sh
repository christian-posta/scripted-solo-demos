echo "http://localhost:8080"
kubectl -n gloo-system port-forward svc/gateway-proxy 8080:80  &> /dev/null &  