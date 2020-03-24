echo "localhost:32000"
kubectl -n gloo-system port-forward svc/dex 32000:32000  &> /dev/null &  