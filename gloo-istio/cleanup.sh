
# Delete Gloo
glooctl uninstall --all

# Delete Bookinfo
kubectl delete -n bookinfo resources/bookinfo.yaml 
kubectl delete ns bookinfo


# Delete Istio
kubectl delete -f resources/istio-1.4-auth-sds.yaml
