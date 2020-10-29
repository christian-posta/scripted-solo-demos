

. ./reset.sh
kubectl delete -f resources/gloo
kubectl delete -f resources/k8s

# delete dex
kubectl delete -f resources/components/dex.yaml -n gloo-system
kubectl delete secret -n gloo-system $(k get secret -n gloo-system | grep dex | awk '{print $1}' )
kubectl delete -n gloo-system cm $(k get cm -n gloo-system | grep dex | awk '{print $1}')

# delete consul
kubectl delete -f resources/components/consul-1.6.2.yaml -n default
k delete pvc $(k get pvc | grep consul | awk '{print $ 1}')

# delete aws
kubectl delete secret aws-credentials -n gloo-system

# delete cert-manager
kubectl delete  -f https://github.com/jetstack/cert-manager/releases/download/v0.14.3/cert-manager.yaml
kubectl delete namespace cert-manager

# delete istio
istioctl x uninstall --purge -y
kubectl delete ns istio-system