kubectl delete -f resources/istio-1.0.yaml
kubectl delete -f resources/loop.yaml

kubectl delete ns calc
kubectl delete ns squash-debugger

kubectl delete crd $(kubectl get crd | grep solo)
kubectl delete clusterrole $(kubectl get clusterrole | grep loop)
kubectl delete clusterrolebinding $(kubectl get clusterrolebinding | grep loop)
kubectl delete clusterrole $(kubectl get clusterrole | grep istio)
kubectl delete clusterrolebinding $(kubectl get clusterrolebinding | grep istio)
kubectl delete clusterrole $(kubectl get clusterrole | grep kiali)
kubectl delete clusterrolebinding $(kubectl get clusterrolebinding | grep kiali)
kubectl delete clusterrole $(kubectl get clusterrole | grep squash)
kubectl delete clusterrolebinding $(kubectl get clusterrolebinding | grep squash)
killall kubectl