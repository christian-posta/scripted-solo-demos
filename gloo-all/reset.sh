
# delete all port forwards
killall kubectl


#########################
# undo the oidc demo
#########################
#. ./30-oidc/reset.sh

#########################
# undo the opa demo
#########################
. ./34-oidc-jwt-opa-rbac/reset.sh

#########################
# reset consul
#########################
. ./40-consul-discovery/reset.sh


#########################
# delete istio injection
#########################
. ./50-gloo-istio/reset.sh

#########################
# delete dev-portal
#########################
. ./60-dev-portal/reset.sh

#########################
# reset VS/authconfig
#########################
kubectl delete virtualservice -n gloo-system --all
kubectl delete authconfig -n gloo-system --all
kubectl apply -f resources/gloo

# Bounce all the sample app pods
kubectl delete po -n default --all