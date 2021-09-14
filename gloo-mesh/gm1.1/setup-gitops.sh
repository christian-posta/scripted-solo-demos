DIR=$(dirname ${BASH_SOURCE})
source env.sh

kubectl --context $MGMT_CONTEXT apply -f ./resources/gloo/argocd-vs.yaml
kubectl --context $MGMT_CONTEXT apply -f ./resources/gloo/gogs-vs.yaml
kubectl --context $MGMT_CONTEXT apply -f ./resources/admin-binding-argo.yaml

./setup-gogs.sh
./setup-argocd.sh
