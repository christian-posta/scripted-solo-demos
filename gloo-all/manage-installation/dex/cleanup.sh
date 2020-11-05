DIR=$(dirname ${BASH_SOURCE})
helm uninstall dex --namespace gloo-system
kubectl delete secret -n gloo-system $(k get secret -n gloo-system | grep dex | awk '{print $1}' )
kubectl delete -n gloo-system cm $(k get cm -n gloo-system | grep dex | awk '{print $1}')

# delete client secret
kubectl delete secret oauth -n gloo-system