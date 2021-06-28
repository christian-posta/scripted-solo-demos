DIR=$(dirname ${BASH_SOURCE})
source ../env.sh
echo "Resetting password for argocd demo..."


# delete the key from the config map
kubectl --context $MGMT_CONTEXT patch secret argocd-secret -n argocd --type=json -p='[{"op": "remove", "path": "/data/admin.password"}]'
kubectl --context $MGMT_CONTEXT patch secret argocd-secret -n argocd --type=json -p='[{"op": "remove", "path": "/data/admin.passwordMtime"}]'


kubectl --context $MGMT_CONTEXT rollout restart -n argocd deploy/argo-cd-argocd-server 
kubectl --context $MGMT_CONTEXT rollout status -n argocd deploy/argo-cd-argocd-server

./get-argo-pw.sh

echo "Username: admin"
echo "Reset Password: $PW"
