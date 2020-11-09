DIR=$(dirname ${BASH_SOURCE})
kubectl patch settings default -n gloo-system --type json  --patch "$(cat $DIR/config/settings-patch-delete.json)"

kubectl delete ratelimitconfig -n gloo-system --all

kubectl apply -n gloo-system -f $DIR/../20-lets-encrypt-edge-tls/default-vs-tls.yaml