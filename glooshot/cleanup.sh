kubectl delete ns glooshot
kubectl delete ns bookinfo
kubectl delete -f resources/istio-1.0.yaml
kubectl delete ns istio-system
killall kubectl
kubectl delete crd $(kubectl get crd | grep solo)
kubectl delete crd $(kubectl get crd | grep istio)
kubectl delete clusterrole $(kubectl get clusterrole | grep glooshot)
kubectl delete clusterrolebinding $(kubectl get clusterrolebinding | grep glooshot)
kubectl delete clusterrole $(kubectl get clusterrole | grep istio)
kubectl delete clusterrolebinding $(kubectl get clusterrolebinding | grep istio)
kubectl delete clusterrole $(kubectl get clusterrole | grep kiali)
kubectl delete clusterrolebinding $(kubectl get clusterrolebinding | grep kiali)