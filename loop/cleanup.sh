supergloo uninstall --name istio-istio-system --namespace default
kubectl delete mesh istio-istio-system -n supergloo-system
kubectl delete install istio-istio-system -n default

kubectl delete -f resources/deploy_loop.yaml

kubectl delete ns calc
kubectl delete ns squash-debugger
kubectl delete ns istio-system
kubectl delete ns supergloo-system

kubectl delete crd $(kubectl get crd | grep solo)
killall kubectl