kubectl patch settings default -n gloo-system --type json  --patch "$(cat ./40-consul-discovery/consul/settings-patch-delete.json)"

kubectl delete upstream consul -n gloo-system
kubectl delete upstream jsonplaceholder -n gloo-system