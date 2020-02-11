kubectl apply -f resources/default-vs.yaml
consul services deregister -http-addr $(glooctl proxy url)  -id jsonplaceholder
kubectl apply -f resources/settings-clean.yaml

