#!/bin/bash

GLOO_MESH_VERSION="1.1.3"

SOURCE_DIR=$PWD
source ./env.sh
source ./relay-ports.sh

istioctl --context $CLUSTER_2 install -y -f ./resources/istio/istio-control-plane-2.yaml

# enable peer auth
kubectl --context $CLUSTER_2 apply -f ./resources/istio/default-peer-authentication.yaml

echo "Installing sample apps"
kubectl --context $CLUSTER_2 create ns istioinaction
kubectl --context $CLUSTER_2 label ns istioinaction istio-injection=enabled
kubectl --context $CLUSTER_2 apply -k resources/sample-apps/overlays/cluster2 -n istioinaction

echo "Registering cluster..."
echo "Using Relay: $RELAY_ADDRESS"

meshctl cluster register enterprise --remote-context=$CLUSTER_2  --relay-server-address $RELAY_ADDRESS $CLUSTER_2_NAME --version $GLOO_MESH_VERSION

## Set up demo sleep app
kubectl --context $CLUSTER_2 create ns sleep
kubectl --context $CLUSTER_2 label ns sleep istio-injection=enabled
kubectl --context $CLUSTER_2 apply -f ./resources/sleep.yaml -n sleep

kubectl --context $CLUSTER_2 label ns default istio-injection-
kubectl --context $CLUSTER_2 apply -f ./resources/sleep.yaml -n default

## Set up gateways for GMG
kubectl --context $CLUSTER_2 create ns gloo-mesh-gateway
kubectl --context $CLUSTER_2 label ns gloo-mesh-gateway istio-injection=enabled
istioctl --context $CLUSTER_2 install -y -f ./resources/ingress-gateways-2.yaml 

helm repo add enterprise-agent https://storage.googleapis.com/gloo-mesh-enterprise/enterprise-agent
helm repo update
helm install enterprise-agent-addons enterprise-agent/enterprise-agent --kube-context=$CLUSTER_2 --version=$GLOO_MESH_VERSION --namespace gloo-mesh-gateway --set enterpriseAgent.enabled=false --set rate-limiter.enabled=true --set ext-auth-service.enabled=true