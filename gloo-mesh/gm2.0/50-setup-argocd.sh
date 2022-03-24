
source ./env.sh

echo "Setting up ArgoCD..."
echo "Reminder: you must have argocd cli installed!!"

read -s

kubectl --context $MGMT create namespace argocd

helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

helm install argo-cd argo/argo-cd --kube-context $MGMT  -n argocd --version 2.17.0 --values ./resources/gitops/argocd/values.yaml

kubectl --context $MGMT rollout status -n argocd deploy/argo-cd-argocd-server 

./scripts/check.sh $MGMT argocd

# Set default pw for argo
kubectl --context $MGMT patch secret -n argocd argocd-secret \
  -p '{"stringData": { "admin.password": "'$(htpasswd -bnBC 10 "" admin123 | tr -d ':\n')'"}}'


# Expose on Gloo Edge API Gateway
kubectl --context $MGMT apply -f ./resources/gloo/argocd-vs.yaml

echo "FATAL::Check this.... we are failing here because we don't want to set up the apps yet.."

echo "Installed vanilla argocd on cluster1 with un/pw admin/admin123"
echo "Installing application..."
kubectl --context $MGMT apply -f ./resources/gitops/argocd/bookinfo-workspace.yaml
kubectl --context $MGMT apply -f ./resources/gitops/argocd/gateways-workspace.yaml


# 
# TODO:ceposta We will need to connect to the other clusters...

kubectl --context $MGMT port-forward -n argocd deploy/argo-cd-argocd-server  8080 &> /dev/null &
PF_PID="$!"
echo "PID of port-forward: $PF_PID"
sleep 5s

function cleanup {
  kill -9 $PF_PID
}

trap cleanup EXIT

argocd login localhost:8080 --plaintext --username admin  --password admin123
argocd cluster add gm-cluster1 
argocd cluster add gm-cluster2
argocd cluster list
