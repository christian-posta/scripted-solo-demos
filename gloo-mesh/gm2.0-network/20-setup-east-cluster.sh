#!/bin/bash

SOURCE_DIR=$PWD
source ./env.sh
source ./scripts/relay-ports.sh

kubectl --context $CLUSTER2 create ns gloo-mesh-gateway
kubectl --context $CLUSTER2 create ns istio-east-west
kubectl --context $CLUSTER2 create ns istio-system

istioctl --context $CLUSTER2 install -y -f ./resources/istio/istio-control-plane-2.yaml --revision=1-11-4-solo

echo "Registering cluster..."
echo "Using Relay: $RELAY_ADDRESS"
helm repo add gloo-mesh-agent https://storage.googleapis.com/gloo-mesh-enterprise/gloo-mesh-agent
helm repo update

kubectl --context $CLUSTER2 create ns gloo-mesh

## set up the relay tokens for cluster 2
kubectl get secret -n gloo-mesh relay-identity-token-secret --context $MGMT -oyaml | kubectl apply --context $CLUSTER2 -f -
kubectl get secret -n gloo-mesh relay-root-tls-secret --context $MGMT -oyaml | kubectl apply --context $CLUSTER2 -f -


## Install the gloo mesh agent
helm install gloo-mesh-agent ./charts/gloo-mesh-agent \
  --kube-context=${CLUSTER2} \
  --namespace gloo-mesh \
  --set glooMeshAgent.image.registry=docker.io \
  --set glooMeshAgent.image.repository=ilackarms/gm-agent \
  --set glooMeshAgent.image.tag=latest \
  --set relay.serverAddress=$RELAY_ADDRESS \
  --set relay.authority=gloo-mesh-mgmt-server.gloo-mesh \
  --set cluster=${CLUSTER2_NAME} \
  --set istiodSidecar.createRoleBinding=true 


kubectl --context $CLUSTER2 label ns gloo-mesh-gateway istio.io/rev=1-11-4-solo

if [ "$USING_KIND" == "true" ] ; then
    istioctl --context $CLUSTER2 install -y -f ./resources/istio/ingress-gateways-2-kind.yaml 
else
    istioctl --context $CLUSTER2 install -y -f ./resources/istio/ingress-gateways-2.yaml 
fi

# Install components/addons for gloo mesh gateway
helm repo add enterprise-agent https://storage.googleapis.com/gloo-mesh-enterprise/enterprise-agent
helm repo update

# Install ext-auth and rate limit to gloo-mesh-gateway namespace
helm install gloo-mesh-agent gloo-mesh-agent/gloo-mesh-agent --kube-context=$CLUSTER2 --version=$GLOO_MESH_VERSION --namespace gloo-mesh-gateway --set glooMeshAgent.enabled=false --set rate-limiter.enabled=true --set ext-auth-service.enabled=true


## Set up demo sleep app
kubectl --context $CLUSTER2 create ns sleep
kubectl --context $CLUSTER2 label ns sleep istio.io/rev=1-11-4-solo
kubectl --context $CLUSTER2 apply -f ./resources/sample-apps/sleep.yaml -n sleep

kubectl --context $CLUSTER2 label ns default istio-injection-
kubectl --context $CLUSTER2 apply -f ./resources/sample-apps/sleep.yaml -n default