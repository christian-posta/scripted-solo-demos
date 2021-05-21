DIR=$(dirname ${BASH_SOURCE})
source env.sh

echo "Setting up ArgoCD..."

kubectl --context $MGMT_CONTEXT create namespace argocd

helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

helm install argo-cd argo/argo-cd --kube-context $MGMT_CONTEXT  -n argocd --version 2.17.0 --values ./resources/gitops/argocd/values.yaml

kubectl --context $MGMT_CONTEXT rollout status -n argocd deploy/argo-cd-argocd-server 

echo "Username/Password for Argo:"
echo "Username: admin"
PW=$(kubectl --context $MGMT_CONTEXT get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2)
echo "Password: $PW"


echo "Setting up GOGS"

kubectl --context $MGMT_CONTEXT create ns gogs
kubectl --context $MGMT_CONTEXT create cm custom-gogs -n gogs --from-file resources/gitops/gogs/app.ini
kubectl --context $MGMT_CONTEXT apply -f resources/gitops/gogs/gogs.yaml
kubectl --context $MGMT_CONTEXT rollout status -n gogs deploy/gogs

# create user
echo "Creating the user..."

kubectl --context $MGMT_CONTEXT -n gogs exec -it deploy/gogs -- /bin/sh -c 'gosu git ./gogs admin create-user --name ceposta --password admin123 --email christian@solo.io --admin'

#kubectl apply -f $DIR/../../resources/gloo/argocd-vs.yaml
echo "WARNING... You need to set up an ingress to expose this argo and gogs server"