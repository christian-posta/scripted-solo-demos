#!/bin/bash

SOURCE_DIR=$PWD
source ./env.sh
source ./scripts/relay-ports.sh

istioctl --context $CLUSTER_2 install -y -f ./resources/istio/istio-control-plane-2.yaml

# enable peer auth
kubectl --context $CLUSTER_2 apply -f ./resources/istio/default-peer-authentication.yaml

echo "Registering cluster..."
echo "Using Relay: $RELAY_ADDRESS"
helm repo add gloo-mesh-agent https://storage.googleapis.com/gloo-mesh-enterprise/gloo-mesh-agent
helm repo update

kubectl --context $CLUSTER_2 create ns gloo-mesh

## set up the relay tokens for cluster 1
kubectl get secret -n gloo-mesh relay-identity-token-secret --context $MGMT_CONTEXT -oyaml | kubectl apply --context $CLUSTER_2 -f -
kubectl get secret -n gloo-mesh relay-root-tls-secret --context $MGMT_CONTEXT -oyaml | kubectl apply --context $CLUSTER_2 -f -


## Install the gloo mesh agent
helm install gloo-mesh-agent gloo-mesh-agent/gloo-mesh-agent \
  --kube-context=${CLUSTER_2} \
  --namespace gloo-mesh \
  --set relay.serverAddress=$RELAY_ADDRESS \
  --set relay.authority=gloo-mesh-mgmt-server.gloo-mesh \
  --set cluster=${CLUSTER_2_NAME} \
  --set istiodSidecar.createRoleBinding=true \
  --version ${GLOO_MESH_VERSION}

echo "Installing sample apps"
kubectl --context $CLUSTER_2 create ns istioinaction
kubectl --context $CLUSTER_2 label ns istioinaction istio-injection=enabled
kubectl --context $CLUSTER_2 apply -k resources/sample-apps/overlays/cluster2 -n istioinaction

## Set up demo sleep app
kubectl --context $CLUSTER_2 create ns sleep
kubectl --context $CLUSTER_2 label ns sleep istio-injection=enabled
kubectl --context $CLUSTER_2 apply -f ./resources/sample-apps/sleep.yaml -n sleep

kubectl --context $CLUSTER_2 label ns default istio-injection-
kubectl --context $CLUSTER_2 apply -f ./resources/sample-apps/sleep.yaml -n default