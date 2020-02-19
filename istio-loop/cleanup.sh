kubectl delete -f resources/istio-1.0.yaml
kubectl delete -f resources/loop.yaml

kubectl delete ns calc
kubectl delete ns squash-debugger

kubectl delete crd $(kubectl get crd | grep solo)
killall kubectl