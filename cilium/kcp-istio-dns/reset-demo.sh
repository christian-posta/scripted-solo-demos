

kubectl delete -f samples/
istioctl uninstall -y --purge
helm uninstall cilium -n kube-system