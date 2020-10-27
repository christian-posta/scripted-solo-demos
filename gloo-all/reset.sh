
# delete all port forwards
killall kubectl

# delete istio
istioctl x uninstall --purge -y
glooctl istio uninject
kubectl delete upstream -n gloo-system default-web-api-8080

# undo the dex/oidc demo
kubectl delete -f ./30-oidc-localhost/dex.yaml -n gloo-system
kubectl -n gloo-system delete clusterissuer --all
kubectl -n gloo-system delete virtualservice letsencrypt
kubectl delete secret -n gloo-system $(k get secret -n gloo-system | grep dex | awk '{print $1}' )
kubectl delete -n gloo-system cm $(k get cm -n gloo-system | grep dex | awk '{print $1}')


# undo the cert-manager/lets encrypt demo
kubectl delete  -f https://github.com/jetstack/cert-manager/releases/download/v0.14.3/cert-manager.yaml

kubectl delete namespace cert-manager
kubectl delete secret nip-io-tls -n default


# undo all of the tls and jwt/oidc demos
kubectl delete cm -n gloo-system allow-jwt
kubectl delete secret -n gloo-system oauth
kubectl delete secret -n gloo-system upstream-tls

## reset settings, get rid of consul discovery
kubectl patch settings default -n gloo-system --type json  --patch "$(cat ./40-consul-discovery/consul/settings-patch-delete.json)"
kubectl delete -f 40-consul-discovery/consul/consul-1.6.2.yaml
kubectl delete upstream consul -n gloo-system
kubectl delete upstream jsonplaceholder -n gloo-system

kubectl delete virtualservice -n gloo-system --all
kubectl delete po --all

kubectl apply -f resources/gloo