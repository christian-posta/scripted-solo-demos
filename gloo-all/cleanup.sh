

. ./reset.sh
kubectl delete -f resources/gloo
kubectl delete -f resources/k8s

#########################
# delete dex
#########################
helm uninstall dex --namespace gloo-system
kubectl delete secret -n gloo-system $(k get secret -n gloo-system | grep dex | awk '{print $1}' )
kubectl delete -n gloo-system cm $(k get cm -n gloo-system | grep dex | awk '{print $1}')

#########################
# delete consul
#########################
kubectl delete -f resources/components/consul-1.6.2.yaml -n default
k delete pvc $(k get pvc | grep consul | awk '{print $ 1}')

#########################
# delete aws secret
#########################
kubectl delete secret aws-credentials -n gloo-system


#########################
# delete cert-manager
#########################
kubectl -n gloo-system delete clusterissuer --all
kubectl delete -n default certificates.cert-manager.io --all
kubectl -n gloo-system delete virtualservice letsencrypt

kubectl delete secret ceposta-gloo-demo-dns -n gloo-system
kubectl delete secret ceposta-auth-demo-dns -n gloo-system
kubectl delete secret ceposta-petstore-demo-dns -n gloo-system
kubectl delete secret ceposta-portal-demo-dns -n gloo-system
kubectl delete secret ceposta-glooui-demo-dns -n gloo-system

kubectl delete  -f https://github.com/jetstack/cert-manager/releases/download/v0.14.3/cert-manager.yaml
kubectl delete namespace cert-manager

# delete istio
istioctl x uninstall --purge -y
kubectl delete ns istio-system

# delete dev portal
kubectl delete -f ./60-dev-portal/petstore-routes.yaml -n default
helm uninstall dev-portal -n dev-portal
kubectl delete namespace dev-portal