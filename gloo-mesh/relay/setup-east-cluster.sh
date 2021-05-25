#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

SOURCE_DIR=$PWD
source env.sh
source relay-ports.sh

echo "Installing Istio"
istioctl1.9 --context $CLUSTER_2 install -y -f resources/istio-control-plane.yaml

echo "Installing sample apps"
kubectl --context $CLUSTER_2 create ns istioinaction
kubectl --context $CLUSTER_2 label ns istioinaction istio-injection=enabled
kubectl --context $CLUSTER_2 apply -k resources/sample-apps/overlays/cluster2 -n istioinaction

echo "Registering cluster..."
echo "Using Relay: $RELAY_ADDRESS"

meshctl cluster register enterprise --remote-context=$CLUSTER_2  --relay-server-address $RELAY_ADDRESS $CLUSTER_2_NAME


# Install Gloo Edge for reaching the cluster
source ~/bin/gloo-license-key-env 
helm install gloo-edge glooe/gloo-ee --kube-context $CLUSTER_2 -f ./gloo/values-east.yaml --version 1.7.7 --create-namespace --namespace gloo-system --set gloo.crds.create=true --set-string license_key=$GLOO_LICENSE