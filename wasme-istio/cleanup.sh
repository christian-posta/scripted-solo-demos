# Delete wasme operator
kubectl delete -f resources/wasme-crds.yaml
kubectl delete -f resources/wasme-operator.yaml

# Delete Istio
istioctl x uninstall --purge

# Delete Bookinfo
kubectl delete -n bookinfo resources/bookinfo.yaml 
kubectl delete ns bookinfo

# Delete wasme 
kubectl delete ns wasme

rm -fr ./filter/