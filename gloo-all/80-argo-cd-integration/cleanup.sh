DIR=$(dirname ${BASH_SOURCE})
echo "dir: $DIR"
kubectl delete -f $DIR/../resources/gloo/petclinic-vs.yaml

# reset git repo
DIR=$(dirname ${BASH_SOURCE})
. $DIR/../manage-installation/gogs/cleanup-petclinic-repo.sh

DIR=$(dirname ${BASH_SOURCE})
. $DIR/../manage-installation/gogs/cleanup-petstore-repo.sh

# delete app from argo
APPNAME="petclinic"
kubectl -n argocd patch app $APPNAME  -p '{"metadata": {"finalizers": ["resources-finalizer.argocd.argoproj.io"]}}' --type merge
kubectl -n argocd delete app $APPNAME 

APPNAME="petstore-portal"
kubectl -n argocd patch app $APPNAME  -p '{"metadata": {"finalizers": ["resources-finalizer.argocd.argoproj.io"]}}' --type merge
kubectl -n argocd delete app $APPNAME 

DIR=$(dirname ${BASH_SOURCE})
. $DIR/../60-dev-portal/reset.sh