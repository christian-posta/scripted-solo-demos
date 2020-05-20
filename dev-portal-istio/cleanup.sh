# Delete wasme operator
kubectl delete -f resources/wasme-crds.yaml
kubectl delete -f resources/wasme-operator.yaml

# Delete Istio
kubectl delete -f resources/istio-1.5.yaml

# Delete Bookinfo
kubectl delete -n bookinfo resources/bookinfo.yaml 
kubectl delete ns bookinfo

# Delete wasme 
kubectl delete ns wasme

rm -fr ./filter/