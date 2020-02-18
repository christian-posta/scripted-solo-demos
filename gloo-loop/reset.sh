kubectl delete pods -n squash-debugger --all > /dev/null 2>&1
kubectl delete taps -n loop-system --all > /dev/null 2>&1

kubectl delete pods -n loop-system --all
killall kubectl