#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

SOURCE_DIR=$PWD
source env.sh
source relay-ports.sh

echo "Installing Istio FIPS 1.8.x"
istioctl1.8 --context $CLUSTER_1 install -y -f resources/istio-control-plane-fips.yaml

echo "Installing sample apps"
kubectl --context $CLUSTER_1 create ns istioinaction
kubectl --context $CLUSTER_1 label ns istioinaction istio-injection=enabled
kubectl --context $CLUSTER_1 apply -k resources/sample-apps/overlays/cluster1 -n istioinaction

echo "Registering cluster..."
echo "Using Relay: $RELAY_ADDRESS"
meshctl cluster register enterprise --remote-context=$CLUSTER_1  --relay-server-address $RELAY_ADDRESS $CLUSTER_1_NAME


# Install Gloo Edge for reaching the cluster
source ~/bin/gloo-license-key-env 
helm install gloo-edge glooe/gloo-ee --kube-context $CLUSTER_1 -f ./gloo/values-west.yaml --version 1.7.7 --create-namespace --namespace gloo-system --set gloo.crds.create=true --set-string license_key=$GLOO_LICENSE
