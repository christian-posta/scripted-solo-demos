
# Delete Gloo
glooctl uninstall --all

# Delete Bookinfo
kubectl delete -n bookinfo -f resources/bookinfo.yaml 
kubectl delete ns bookinfo


# Delete Istio
istioctl manifest generate --set profile=minimal | kubectl delete -f -
