
source ./env-workshop.sh

echo "Setting up ArgoCD..."

kubectl --context $CLUSTER1 create namespace argocd

helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

helm install argo-cd argo/argo-cd --kube-context $CLUSTER1  -n argocd --version 2.17.0 --values ./gitops/argocd/values.yaml

kubectl --context $CLUSTER1 rollout status -n argocd deploy/argo-cd-argocd-server 

# Set default pw for argo
kubectl --context $CLUSTER1 patch secret -n argocd argocd-secret \
  -p '{"stringData": { "admin.password": "'$(htpasswd -bnBC 10 "" admin123 | tr -d ':\n')'"}}'


echo "Installed vanilla argocd on cluster1 with un/pw admin/admin123"
echo "Installing application..."
kubectl --context $CLUSTER1 apply -f ./gitops/argocd/bookinfo-workspace.yaml
kubectl --context $CLUSTER1 apply -f ./gitops/argocd/gateways-workspace.yaml