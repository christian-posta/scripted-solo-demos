#!/bin/bash

GLOO_MESH_VERSION="1.1.5"


SOURCE_DIR=$PWD
source ./env.sh
source ~/bin/gloo-mesh-license-env


kubectl config use-context $MGMT_CONTEXT
helm repo add gloo-mesh-enterprise https://storage.googleapis.com/gloo-mesh-enterprise/gloo-mesh-enterprise
helm repo update

echo "Upgrading the management plane..."
helm upgrade gloo-mesh-enterprise gloo-mesh-enterprise/gloo-mesh-enterprise --kube-context $MGMT_CONTEXT -n gloo-mesh --version=$GLOO_MESH_VERSION --set licenseKey=${GLOO_MESH_LICENSE} --set rbac-webhook.enabled=false --set metricsBackend.prometheus.enabled=true --set gloo-mesh-ui.relayClientAuthority=enterprise-networking.gloo-mesh 

echo "Upgrading the west cluster..."
helm upgrade enterprise-agent --kube-context $CLUSTER_1 --namespace gloo-mesh https://storage.googleapis.com/gloo-mesh-enterprise/enterprise-agent/enterprise-agent-$GLOO_MESH_VERSION.tgz

echo "Upgrading the east cluster..."
helm upgrade enterprise-agent --kube-context $CLUSTER_2 --namespace gloo-mesh https://storage.googleapis.com/gloo-mesh-enterprise/enterprise-agent/enterprise-agent-$GLOO_MESH_VERSION.tgz


