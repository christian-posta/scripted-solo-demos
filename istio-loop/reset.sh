./patch-service2-orig.sh

kubectl delete pods -n squash-debugger --all > /dev/null 2>&1
kubectl delete envoyfilters -n loop-system --all > /dev/null 2>&1
kubectl delete taps -n loop-system --all > /dev/null 2>&1

kubectl delete pods -n calc --all
kubectl delete pods -n loop-system --all
killall kubectl