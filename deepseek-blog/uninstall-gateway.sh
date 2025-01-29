helm uninstall gloo-gateway -n gloo-system
kubectl delete namespace gloo-system
kubectl get crds | grep 'solo.io' | awk '{print $1}' | xargs kubectl delete crd