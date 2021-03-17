TOP_DIR=$(dirname ${BASH_SOURCE})

pushd $TOP_DIR
kubectl create -f ../60-dev-portal/complete/configmaps
kubectl apply -f ../60-dev-portal/complete/routes-default.yaml
kubectl apply -f ../60-dev-portal/complete/secret-oidc-client.yaml
kubectl apply -f ../60-dev-portal/complete/group-oidc-gloo.yaml


. ../manage-installation/gogs/setup-petstore-repo.sh
. ../manage-installation/gogs/setup-petclinic-repo.sh


kubectl apply -f ../manage-installation/argocd/petclinic-application.yaml
kubectl apply -f ../manage-installation/argocd/portal-application.yaml
popd