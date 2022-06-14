#!/bin/bash

SOURCE_DIR=$PWD
source ./env.sh
source ./scripts/relay-ports.sh

kubectl --context $CLUSTER1 create ns gloo-mesh-gateway
kubectl --context $CLUSTER1 create ns istio-east-west
kubectl --context $CLUSTER1 create ns istio-system

istioctl --context $CLUSTER1 install -y -f ./resources/istio/istio-control-plane-1.yaml --revision=1-11-5-solo


echo "Registering cluster..."
echo "Using Relay: $RELAY_ADDRESS"
helm repo add gloo-mesh-agent https://storage.googleapis.com/gloo-mesh-enterprise/gloo-mesh-agent
helm repo update

kubectl --context $CLUSTER1 create ns gloo-mesh

## set up the relay tokens for cluster 1
kubectl get secret -n gloo-mesh relay-identity-token-secret --context $MGMT -oyaml | kubectl apply --context $CLUSTER1 -f -
kubectl get secret -n gloo-mesh relay-root-tls-secret --context $MGMT -oyaml | kubectl apply --context $CLUSTER1 -f -


## Install the gloo mesh agent
helm install gloo-mesh-agent ./charts/gloo-mesh-agent \
  --kube-context=${CLUSTER1} \
  --namespace gloo-mesh \
  --set glooMeshAgent.image.registry=docker.io \
  --set glooMeshAgent.image.repository=ilackarms/gm-agent \
  --set glooMeshAgent.image.tag=latest \
  --set relay.serverAddress=$RELAY_ADDRESS \
  --set relay.authority=gloo-mesh-mgmt-server.gloo-mesh \
  --set cluster=${CLUSTER1_NAME} \
  --set istiodSidecar.createRoleBinding=true 



kubectl --context $CLUSTER1 label ns gloo-mesh-gateway istio.io/rev=1-11-5-solo

if [ "$USING_KIND" == "true" ] ; then
    istioctl --context $CLUSTER1 install -y -f ./resources/istio/ingress-gateways-1-kind.yaml 
else
    istioctl --context $CLUSTER1 install -y -f ./resources/istio/ingress-gateways-1.yaml 
fi

# Install components/addons for gloo mesh gateway
helm repo add enterprise-agent https://storage.googleapis.com/gloo-mesh-enterprise/enterprise-agent
helm repo update

# Install ext-auth and rate limit to gloo-mesh-gateway namespace
helm install gloo-mesh-agent gloo-mesh-agent/gloo-mesh-agent --kube-context=$CLUSTER1 --version=$GLOO_MESH_VERSION --namespace gloo-mesh-gateway --set glooMeshAgent.enabled=false --set rate-limiter.enabled=true --set ext-auth-service.enabled=true


## Set up demo sleep app
kubectl --context $CLUSTER1 create ns sleep
kubectl --context $CLUSTER1 label ns sleep  istio.io/rev=1-11-5-solo
kubectl --context $CLUSTER1 apply -f ./resources/sample-apps/sleep.yaml -n sleep

kubectl --context $CLUSTER1 label ns default istio-injection-
kubectl --context $CLUSTER1 apply -f ./resources/sample-apps/sleep.yaml -n default