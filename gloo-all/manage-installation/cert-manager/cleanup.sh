DIR=$(dirname ${BASH_SOURCE})
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