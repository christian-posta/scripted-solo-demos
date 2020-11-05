DIR=$(dirname ${BASH_SOURCE})
kubectl patch settings default -n gloo-system --type json  --patch "$(cat $DIR/consul/settings-patch-delete.json)"

kubectl delete upstream consul -n gloo-system
kubectl delete upstream jsonplaceholder -n gloo-system