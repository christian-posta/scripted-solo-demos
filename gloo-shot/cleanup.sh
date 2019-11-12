kubectl delete ns glooshot
kubectl delete ns bookinfo
supergloo uninstall --name istio-istio-system 
kubectl delete mesh istio-istio-system -n supergloo-system
kubectl delete ns istio-system
killall kubectl
kubectl delete crd $(kubectl get crd | grep solo)
kubectl delete crd $(kubectl get crd | grep istio)
