kubectl apply -f resources/gateway-clean.yaml
kubectl delete virtualservice default -n gloo-system
rm -fr ./filter/