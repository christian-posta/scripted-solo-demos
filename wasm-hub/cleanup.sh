kubectl apply -f resources/gateway-v2-clean.yaml
kubectl delete virtualservice default -n gloo-system
rm -fr ./filter/