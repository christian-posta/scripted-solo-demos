
# delete all port forwards
killall kubectl

# delete istio injection
kubectl label namespace default istio-injection-
glooctl istio uninject
kubectl delete upstream -n gloo-system default-web-api-8080

# undo the dex/oidc demo
#kubectl delete -f ./30-oidc-localhost/dex.yaml -n gloo-system




# undo the cert-manager/lets encrypt demo

kubectl -n gloo-system delete clusterissuer --all
kubectl -n gloo-system delete virtualservice letsencrypt

kubectl delete secret nip-io-tls -n default


# undo all of the tls and jwt/oidc demos
kubectl delete cm -n gloo-system allow-jwt
kubectl delete secret -n gloo-system oauth
kubectl delete secret -n gloo-system upstream-tls

## reset settings, get rid of consul discovery
kubectl patch settings default -n gloo-system --type json  --patch "$(cat ./40-consul-discovery/consul/settings-patch-delete.json)"

kubectl delete upstream consul -n gloo-system
kubectl delete upstream jsonplaceholder -n gloo-system


kubectl delete virtualservice -n gloo-system --all
kubectl delete po --all

kubectl apply -f resources/gloo