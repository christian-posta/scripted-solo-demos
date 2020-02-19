kubectl delete ns glooshot
kubectl delete ns bookinfo
kubectl delete -f resources/istio-1.0.yaml
kubectl delete ns istio-system
killall kubectl
kubectl delete crd $(kubectl get crd | grep solo)
kubectl delete crd $(kubectl get crd | grep istio)
