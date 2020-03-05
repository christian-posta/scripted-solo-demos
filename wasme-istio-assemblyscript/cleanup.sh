# Delete Istio
kubectl delete -f resources/istio-1.5.yaml

# Delete Bookinfo
kubectl delete -n bookinfo resources/bookinfo.yaml 
kubectl delete ns bookinfo

# Delete wasme 
kubectl delete ns wasme

rm -fr ./filter/