# Delete dex
kubectl delete -f resources/dex.yaml

kubectl delete -f resources/dex-oidc-authconfig.yaml
kubectl delete -f resources/dex-oidc-vs.yaml

# Delete petlinic
kubectl delete -f resources/petclinic.yaml

kubectl delete secret oauth -n gloo-system

kubectl delete secret -n gloo-system $(kubectl get secret -n gloo-system | grep dex | awk '{ print $1 }')


killall kubectl