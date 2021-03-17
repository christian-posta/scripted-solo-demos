DIR=$(dirname ${BASH_SOURCE})

kubectl create namespace argocd

helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

helm install argo-cd argo/argo-cd -n argocd --version 2.17.0 --values $DIR/values.yaml

kubectl rollout status -n argocd deploy/argo-cd-argocd-server 

echo "Username/Password for Argo:"
echo "Username: admin"
PW=$(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2)
echo "Password: $PW"

echo "Creating Gloo VS"
kubectl apply -f $DIR/../../resources/gloo/argocd-vs.yaml
echo "Created."