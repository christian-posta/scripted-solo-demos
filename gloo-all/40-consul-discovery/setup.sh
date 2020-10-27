kubectl apply -f ./consul/consul-1.6.2.yaml
kubectl apply -f default-vs.yaml


kubectl patch settings default -n gloo-system --type merge --patch "$(cat ./consul/settings-patch.yaml)"