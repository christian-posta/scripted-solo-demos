#!/bin/bash

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

if $USING_KIND ; then
    istioctl --context $CLUSTER_2 install -y -f ./resources/istio/ingress-gateways-2-kind.yaml 
else
    istioctl --context $CLUSTER_2 install -y -f ./resources/istio/ingress-gateways-2.yaml 
fi


helm repo add enterprise-agent https://storage.googleapis.com/gloo-mesh-enterprise/enterprise-agent
helm repo update
helm install enterprise-agent-addons enterprise-agent/enterprise-agent --kube-context=$CLUSTER_2 --version=$GLOO_MESH_VERSION --namespace gloo-mesh-gateway --set enterpriseAgent.enabled=false --set rate-limiter.enabled=true --set ext-auth-service.enabled=true

# upgrade the agent to create role bindings for istio
#helm upgrade enterprise-agent --kube-context $CLUSTER_2 --namespace gloo-mesh https://storage.googleapis.com/gloo-mesh-enterprise/enterprise-agent/enterprise-agent-$GLOO_MESH_VERSION.tgz --set istiodSidecar.createRoleBinding=true




helm upgrade -n gloo-mesh enterprise-agent enterprise-agent/enterprise-agent --kube-context=$CLUSTER_2 --version=$GLOO_MESH_VERSION -f resources/gloo-mesh-install/agent-values-cluster-2.yaml

# secret for vault
kubectl create secret generic vault-token --context $CLUSTER_2 -n gloo-mesh --from-literal=token=root

# deploy bookinfo
kubectl create namespace bookinfo --context $CLUSTER_2
kubectl label namespace bookinfo istio-injection=enabled --context $CLUSTER_2 --overwrite
kubectl --context $CLUSTER_2 -n bookinfo apply -f https://raw.githubusercontent.com/istio/istio/1.7.3/samples/bookinfo/platform/kube/bookinfo.yaml
kubectl --context $CLUSTER_2 -n bookinfo apply -f https://raw.githubusercontent.com/istio/istio/1.7.3/samples/bookinfo/networking/bookinfo-gateway.yaml

until [ $(kubectl --context $CLUSTER_2 -n bookinfo get pods -o jsonpath='{range .items[*].status.containerStatuses[*]}{.ready}{"\n"}{end}' | grep false -c) -eq 0 ]; do
  echo "Waiting for all the pods of the bookinfo namespace to become ready"
  sleep 1
done