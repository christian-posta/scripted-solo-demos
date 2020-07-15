rm *.crt
rm *.key
. ./reset.sh

kubectl delete -f resources/blue-service.yaml
kubectl delete -f resources/green-service.yaml
kubectl delete -f resources/default-vs.yaml