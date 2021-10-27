#!/bin/bash

SOURCE_DIR=$PWD
source ./env.sh
source ~/bin/gloo-mesh-license-env


kubectl config use-context $MGMT_CONTEXT
helm repo add gloo-mesh-enterprise https://storage.googleapis.com/gloo-mesh-enterprise/gloo-mesh-enterprise
helm repo update

# we may need a beta version?
# helm search repo gloo-mesh-enterprise --devel

kubectl create namespace gloo-mesh

# configs for gmg will go into this namespace:
kubectl create namespace gloo-mesh-gateway

# Helm Install GM
helm install gloo-mesh-enterprise gloo-mesh-enterprise/gloo-mesh-enterprise --kube-context $MGMT_CONTEXT -n gloo-mesh --version=$GLOO_MESH_VERSION --set licenseKey=${GLOO_MESH_LICENSE} --set rbac-webhook.enabled=false --set metricsBackend.prometheus.enabled=true --set gloo-mesh-ui.relayClientAuthority=enterprise-networking.gloo-mesh 

#
# helm upgrade --install gloo-mesh-enterprise gloo-mesh-enterprise/gloo-mesh-enterprise --kube-context $MGMT_CONTEXT -n gloo-mesh --version=$GLOO_MESH_VERSION --set licenseKey=${GLOO_MESH_LICENSE} --set rbac-webhook.enabled=false --set metricsBackend.prometheus.enabled=true --set gloo-mesh-ui.relayClientAuthority=enterprise-networking.gloo-mesh 


kubectl --context $MGMT_CONTEXT -n gloo-mesh rollout status deploy/enterprise-networking 
kubectl --context $MGMT_CONTEXT -n gloo-mesh rollout status deploy/dashboard
kubectl --context $MGMT_CONTEXT -n gloo-mesh rollout status deploy/prometheus-server


kubectl --context $MGMT_CONTEXT apply -f ./resources/admin-binding-ceposta.yaml

## Let's install Gloo Edge to expose argo/gogs
source ~/bin/gloo-license-key-env 
helm repo add glooe http://storage.googleapis.com/gloo-ee-helm
helm repo update
helm install gloo-edge glooe/gloo-ee --kube-context $MGMT_CONTEXT -f ./resources/gloo/values-mgmtplane.yaml --version 1.7.7 --create-namespace --namespace gloo-system --set gloo.crds.create=true --set-string license_key=$GLOO_LICENSE

kubectl --context $MGMT_CONTEXT -n gloo-system rollout status deploy/gloo

kubectl --context $MGMT_CONTEXT apply -f ./resources/gloo/gloo-mesh-ui-us.yaml
kubectl --context $MGMT_CONTEXT apply -f ./resources/gloo/gloo-mesh-ui-vs.yaml

echo "Gloo Mesh read-only UI available on http://dashboard.gloo-mesh.istiodemos.io/"

#echo "setting up gitops"
#./setup-gitops.sh

kubectl --context $MGMT_CONTEXT create ns demo-config


