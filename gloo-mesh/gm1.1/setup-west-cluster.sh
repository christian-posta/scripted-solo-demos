#!/bin/bash

SOURCE_DIR=$PWD
source ./env.sh
source ./relay-ports.sh

istioctl --context $CLUSTER_1 install -y -f ./resources/istio/istio-control-plane-1.yaml

# enable peer auth
kubectl --context $CLUSTER_1 apply -f ./resources/istio/default-peer-authentication.yaml

echo "Installing sample apps"
kubectl --context $CLUSTER_1 create ns istioinaction
kubectl --context $CLUSTER_1 label ns istioinaction istio-injection=enabled
kubectl --context $CLUSTER_1 apply -k resources/sample-apps/overlays/cluster1 -n istioinaction

echo "Registering cluster..."
echo "Using Relay: $RELAY_ADDRESS"
meshctl cluster register enterprise --remote-context=$CLUSTER_1  --relay-server-address $RELAY_ADDRESS $CLUSTER_1_NAME --version $GLOO_MESH_VERSION


## Set up demo sleep app
kubectl --context $CLUSTER_1 create ns sleep
kubectl --context $CLUSTER_1 label ns sleep istio-injection=enabled
kubectl --context $CLUSTER_1 apply -f ./resources/sleep.yaml -n sleep

kubectl --context $CLUSTER_1 label ns default istio-injection-
kubectl --context $CLUSTER_1 apply -f ./resources/sleep.yaml -n default

## Set up gateways for GMG
kubectl --context $CLUSTER_1 create ns gloo-mesh-gateway
kubectl --context $CLUSTER_1 label ns gloo-mesh-gateway istio-injection=enabled

if [ "$USING_KIND" == "true" ] ; then
    istioctl --context $CLUSTER_1 install -y -f ./resources/istio/ingress-gateways-1-kind.yaml 
else
    istioctl --context $CLUSTER_1 install -y -f ./resources/istio/ingress-gateways-1.yaml 
fi



# Install components/addons for gloo mesh gateway
helm repo add enterprise-agent https://storage.googleapis.com/gloo-mesh-enterprise/enterprise-agent
helm repo update
helm install enterprise-agent-addons enterprise-agent/enterprise-agent --kube-context=$CLUSTER_1 --version=$GLOO_MESH_VERSION --namespace gloo-mesh-gateway --set enterpriseAgent.enabled=false --set rate-limiter.enabled=true --set ext-auth-service.enabled=true

# upgrade the agent to create role bindings for istio
#helm upgrade enterprise-agent --kube-context $CLUSTER_1 --namespace gloo-mesh https://storage.googleapis.com/gloo-mesh-enterprise/enterprise-agent/enterprise-agent-$GLOO_MESH_VERSION.tgz --set istiodSidecar.createRoleBinding=true

if [ "$USING_KIND" == "true" ] ; then
  helm upgrade -n gloo-mesh enterprise-agent enterprise-agent/enterprise-agent --kube-context=$CLUSTER_1 --version=$GLOO_MESH_VERSION -f resources/gloo-mesh-install/agent-values-cluster-1-kind.yaml
else
  helm upgrade -n gloo-mesh enterprise-agent enterprise-agent/enterprise-agent --kube-context=$CLUSTER_1 --version=$GLOO_MESH_VERSION -f resources/gloo-mesh-install/agent-values-cluster-1.yaml
fi


# secret for vault
kubectl create secret generic vault-token --context $CLUSTER_1 -n gloo-mesh --from-literal=token=root


# deploy bookinfo

kubectl create namespace bookinfo --context $CLUSTER_1
kubectl label namespace bookinfo istio-injection=enabled --context $CLUSTER_1 --overwrite 
kubectl --context $CLUSTER_1 -n bookinfo apply -f https://raw.githubusercontent.com/istio/istio/1.7.3/samples/bookinfo/platform/kube/bookinfo.yaml -l 'app,version notin (v3)'
kubectl --context $CLUSTER_1 -n bookinfo apply -f https://raw.githubusercontent.com/istio/istio/1.7.3/samples/bookinfo/platform/kube/bookinfo.yaml -l 'account'
kubectl --context $CLUSTER_1 -n bookinfo apply -f https://raw.githubusercontent.com/istio/istio/1.7.3/samples/bookinfo/networking/bookinfo-gateway.yaml

until [ $(kubectl --context $CLUSTER_1 -n bookinfo get pods -o jsonpath='{range .items[*].status.containerStatuses[*]}{.ready}{"\n"}{end}' | grep false -c) -eq 0 ]; do
  echo "Waiting for all the pods of the bookinfo namespace to become ready"
  sleep 1
done