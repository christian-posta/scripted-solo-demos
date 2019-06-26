./patch-service2-orig.sh

kubectl delete -f resources/tap.yaml
kubectl delete -f resources/envoyfilter.yaml
kubectl delete pods -n calc --all