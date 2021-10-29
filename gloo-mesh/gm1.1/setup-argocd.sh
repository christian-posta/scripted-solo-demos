DIR=$(dirname ${BASH_SOURCE})
source env.sh

echo "Setting up ArgoCD..."

kubectl --context $MGMT_CONTEXT create namespace argocd

helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

helm install argo-cd argo/argo-cd --kube-context $MGMT_CONTEXT  -n argocd --version 2.17.0 --values ./resources/gitops/argocd/values.yaml

kubectl --context $MGMT_CONTEXT rollout status -n argocd deploy/argo-cd-argocd-server 

kubectl --context $MGMT_CONTEXT apply -f ./resources/gloo/argocd-vs.yaml
kubectl --context $MGMT_CONTEXT apply -f ./resources/admin-binding-argo.yaml

echo "Waiting for gloo edge to publish the argo routes...."
sleep 5s

echo "Username/Password for Argo:"
echo "Username: admin"
PW=$(kubectl --context $MGMT_CONTEXT get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2)
echo "Admin Username: admin"
echo "Admin Password: $PW"

kubectl --context $MGMT_CONTEXT apply -f resources/gitops/argocd/gloo-mesh-application.yaml