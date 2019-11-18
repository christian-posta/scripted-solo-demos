
source ./cleanup.sh
kubectl delete ns istio-system
kubectl delete crd $(kubectl get crd | grep istio | awk '{ print $1 }')