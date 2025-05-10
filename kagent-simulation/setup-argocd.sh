
source ./env.sh

echo "Setting up ArgoCD..."

kubectl --context $CONTEXT create namespace argocd

helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# could do this "all in one" instead of helm
#export ARGOCD_VERSION=v2.7.0
#kubectl create namespace argocd
#kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/$ARGOCD_VERSION/manifests/core-install.yaml

helm upgrade --install argocd argo/argo-cd --kube-context $CONTEXT --version 8.0.0 -n argocd --values ./resources/gitops/argocd/values.yaml


kubectl --context $CONTEXT rollout status -n argocd deploy/argocd-server 

# Set default pw for argo
kubectl --context $CONTEXT patch secret -n argocd argocd-secret \
  -p '{"stringData": { "admin.password": "'$(htpasswd -bnBC 10 "" admin123 | tr -d ':\n')'"}}'


echo "Installed vanilla argocd on CONTEXT with un/pw admin/admin123"
echo "Installing application..."

kubectl --context $CONTEXT apply -f ./resources/gitops/argocd/application.yaml
