crd=istio
kubectl delete crd $(kubectl get crd | grep $crd)
crd=solo
kubectl delete crd $(kubectl get crd | grep $crd)
crd=smi
kubectl delete crd $(kubectl get crd | grep $crd)

