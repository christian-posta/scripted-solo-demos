kubectl delete -f resources/tap.yaml
kubectl delete -f resources/loop.yaml
kubectl delete -f resources/gloo.yaml
kubectl delete -f resources/calc.yaml
kubectl delete ns calc squash-debugger
killall kubectl