
# delete all port forwards
killall kubectl

#########################
# delete istio injection
#########################
kubectl label namespace default istio-injection-
glooctl istio uninject
kubectl delete upstream -n gloo-system default-web-api-8080
kubectl delete -f default-peerauth-strict.yaml


#########################
# undo all of the tls and jwt/oidc demos
#########################
kubectl delete cm -n gloo-system allow-jwt

#########################
# reset consul
#########################
kubectl patch settings default -n gloo-system --type json  --patch "$(cat ./40-consul-discovery/consul/settings-patch-delete.json)"

kubectl delete upstream consul -n gloo-system
kubectl delete upstream jsonplaceholder -n gloo-system

#########################
# reset VS/authconfig
#########################
kubectl delete virtualservice -n gloo-system --all
kubectl delete authconfig -n gloo-system --all
kubectl apply -f resources/gloo/default-vs.yaml

kubectl delete po -n default --all