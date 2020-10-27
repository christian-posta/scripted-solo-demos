
killall kubectl


kubectl -n gloo-system delete clusterissuer --all
kubectl -n gloo-system delete virtualservice letsencrypt

kubectl delete  -f https://github.com/jetstack/cert-manager/releases/download/v0.14.3/cert-manager.yaml

kubectl delete namespace cert-manager
kubectl delete secret nip-io-tls -n default

kubectl delete -f dex.yaml -n gloo-system
kubectl delete secret -n gloo-system $(k get secret -n gloo-system | grep dex | awk '{print $1}' )
kubectl delete -n gloo-system cm $(k get cm -n gloo-system | grep dex | awk '{print $1}')

kubectl delete cm -n gloo-system allow-jwt
kubectl delete secret -n gloo-system oauth
kubectl delete secret -n gloo-system upstream-tls
kubectl delete virtualservice -n gloo-system --all