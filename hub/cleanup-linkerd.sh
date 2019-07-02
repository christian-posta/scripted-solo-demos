crd=linkerd
kubectl delete crd $(kubectl get crd | grep $crd)
kubectl delete ns linkerd
kubectl delete clusterrole $(kubectl get clusterrole | grep linkerd)
kubectl delete clusterrolebinding $(kubectl get clusterrolebinding |  grep linkerd )