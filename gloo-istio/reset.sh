kubectl delete vs default -n gloo-system
kubectl apply -f resources/productpage-upstream.yaml
kubectl apply -f resources/gateway-proxy-deploy.yaml

# heavier hand reset
#glooctl uninstall --all