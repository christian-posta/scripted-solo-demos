DIR=$(dirname ${BASH_SOURCE})
source env.sh

echo "Using kube context: $CONTEXT"
echo "Setting up ArgoCD..."

kubectl --context $CONTEXT create namespace argocd

helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

helm install argo-cd argo/argo-cd --kube-context $CONTEXT  -n argocd --version 2.17.0 --values ./resources/gitops/argocd/values.yaml

kubectl --context $CONTEXT rollout status -n argocd deploy/argo-cd-argocd-server 

# Set default pw for argo
kubectl patch secret -n argocd argocd-secret \
  -p '{"stringData": { "admin.password": "'$(htpasswd -bnBC 10 "" admin123 | tr -d ':\n')'"}}'



kubectl --context $CONTEXT apply -f resources/gitops/argocd/gloo-mesh-application.yaml