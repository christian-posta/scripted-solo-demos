
kubectl -n gloo-system delete clusterissuer --all
kubectl -n gloo-system delete virtualservice letsencrypt

kubectl delete  -f https://github.com/jetstack/cert-manager/releases/download/v0.14.3/cert-manager.yaml

kubectl delete namespace cert-manager
kubectl delete secret nip-io-tls
kubectl apply -f default-vs.yaml