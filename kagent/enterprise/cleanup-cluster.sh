
helm uninstall kagent-enterprise -n kagent
helm uninstall kagent -n kagent
helm uninstall kagent-crds -n kagent
helm uninstall gloo-operator -n kagent

helm uninstall kgateway -n kagent
helm uninstall kgateway-crds -n kagent

kubectl delete ns kagent
kubectl delete ns kgateway-system

# we won't delete keycloak