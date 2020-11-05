DIR=$(dirname ${BASH_SOURCE})
# delete istio
istioctl x uninstall --purge -y
kubectl delete ns istio-system

kubectl delete cm -n default istio-ca-root-cert
kubectl delete cm -n gloo-system istio-ca-root-cert
kubectl delete cm -n kube-system istio-ca-root-cert
kubectl delete cm -n kube-public istio-ca-root-cert
kubectl delete cm -n kube-node-lease istio-ca-root-cert