#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

SOURCE_DIR=$PWD
source env.sh
source relay-ports.sh

echo "Installing Istio"
istioctl1.9 --context $CLUSTER_2 install -y -f resources/istio-control-plane.yaml

# enable peer auth
kubectl --context $CLUSTER_2 apply -f resources/istio/default-peer-authentication.yaml

echo "Installing sample apps"
kubectl --context $CLUSTER_2 create ns istioinaction
kubectl --context $CLUSTER_2 label ns istioinaction istio-injection=enabled
kubectl --context $CLUSTER_2 apply -k resources/sample-apps/overlays/cluster2 -n istioinaction

echo "Registering cluster..."
echo "Using Relay: $RELAY_ADDRESS"

meshctl cluster register enterprise --remote-context=$CLUSTER_2  --relay-server-address $RELAY_ADDRESS $CLUSTER_2_NAME

## Set up demo sleep app
kubectl --context $CLUSTER_2 create ns sleep
kubectl --context $CLUSTER_2 label ns sleep istio-injection=enabled
kubectl --context $CLUSTER_2 apply -f resources/sleep.yaml -n sleep

kubectl --context $CLUSTER_2 label ns default istio-injection-
kubectl --context $CLUSTER_2 apply -f resources/sleep.yaml -n default


# Install Gloo Edge for reaching the cluster
source ~/bin/gloo-license-key-env 
helm install gloo-edge glooe/gloo-ee --kube-context $CLUSTER_2 -f ./gloo/values-east.yaml --version 1.7.7 --create-namespace --namespace gloo-system --set gloo.crds.create=true --set-string license_key=$GLOO_LICENSE

kubectl --context $CLUSTER_2 rollout status deploy/gloo -n gloo-system
kubectl --context $CLUSTER_2 rollout status deploy/gateway-proxy -n gloo-system 

kubectl config use-context $CLUSTER_2
glooctl istio inject

kubectl --context $CLUSTER_2 -n gloo-system set env deployment/gateway-proxy ISTIO_META_CLUSTER_ID=$CLUSTER_2_NAME

# Register cluster for gloo federation
# unfortunately, glooctl doesn't allow for context passing, so we ahve to switch to it
kubectl config use-context $MGMT_CONTEXT
glooctl cluster register --cluster-name cluster-2 --remote-context $CLUSTER_2
kubectl --context $CLUSTER_2 apply -f ./gloo/certs/secrets/edge-east-failover-downstream.yaml
kubectl --context $CLUSTER_2 apply -f ./gloo/certs/secrets/edge-east-failover-upstream.yaml
kubectl --context $CLUSTER_2 apply -f ./resources/gloo-ingress/web-api-ingress.yaml
kubectl --context $CLUSTER_2 apply -f ./resources/gloo-ingress/web-api-upstream-istio-mtls.yaml
