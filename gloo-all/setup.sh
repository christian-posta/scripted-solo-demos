# set up helm
helm repo add stable https://charts.helm.sh/stable
helm repo add dev-portal https://storage.googleapis.com/dev-portal-helm
helm repo update

# Set up services
. ~/bin/create-aws-secret

DIR=$(dirname ${BASH_SOURCE})
#########################
# istio
#########################
$DIR/manage-installation/istio/setup.sh

#########################
# dex
#########################
$DIR/manage-installation/dex/setup.sh

#########################
# dex
#########################
$DIR/manage-installation/dev-portal/setup.sh

#########################
# cert consul
#########################
$DIR/manage-installation/consul/setup.sh

#########################
# cert manager
#########################
$DIR/manage-installation/cert-manager/setup.sh


$DIR/prepare-certs.sh ceposta-gloo-demo
$DIR/prepare-certs.sh ceposta-auth-demo
$DIR/prepare-certs.sh ceposta-apis-demo


kubectl apply -f resources/k8s
kubectl apply -f resources/gloo