
. ./reset.sh

DIR=$(dirname ${BASH_SOURCE})
kubectl delete -f resources/gloo
kubectl delete -f resources/k8s

#########################
# delete dex
#########################
$DIR/manage-installation/dex/cleanup.sh

#########################
# delete istio
#########################
$DIR/manage-installation/istio/cleanup.sh


#########################
# delete consul
#########################
$DIR/manage-installation/consul/cleanup.sh


#########################
# delete cert-manager
#########################
$DIR/manage-installation/cert-manager/cleanup.sh

#########################
# gogs
#########################
$DIR/manage-installation/gogs/cleanup.sh

#########################
# argo
#########################
$DIR/manage-installation/argocd/cleanup.sh

#########################
# delete dev-portal
#########################
$DIR/manage-installation/dev-portal/cleanup.sh

#########################
# delete aws secret
#########################
kubectl delete secret aws-credentials -n gloo-system

#########################
# cleanup DNS secrets
#########################
kubectl delete secret -n gloo-system $(kubectl -n gloo-system get secret | grep demo-dns | awk '{print $1}')