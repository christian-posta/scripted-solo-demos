
# delete all port forwards
killall kubectl

#########################
# undo the oidc demo
#########################
. ./30-oidc/reset.sh

#########################
# reset opa
#########################
. ./34-oidc-jwt-opa-rbac/reset.sh

#########################
# reset consul
#########################
. ./40-consul-discovery/reset.sh

#########################
#  istio injection
#########################
. ./50-gloo-istio/reset.sh

#########################
#  dev-portal
#########################
. ./60-dev-portal/reset.sh

#########################
# reset rate-limit
#########################
. ./70-rate-limiting/reset.sh

#########################
# reset VS/authconfig
#########################
kubectl delete virtualservice -n gloo-system --all
kubectl delete authconfig -n gloo-system --all
kubectl apply -f resources/gloo

# Bounce all the sample app pods
kubectl delete po -n default --all

kubectl delete ns squash-debugger