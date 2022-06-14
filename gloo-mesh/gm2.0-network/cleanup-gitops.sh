
source ./env.sh


kubectl --context ${MGMT} delete ns gogs
kubectl --context ${MGMT} delete ns argocd

