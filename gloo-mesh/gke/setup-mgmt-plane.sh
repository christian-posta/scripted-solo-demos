#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

SOURCE_DIR=$PWD
source env.sh

kind create cluster --name smh-management

kubectl config use-context $MGMT_CONTEXT

helm repo add gloo-mesh-enterprise https://storage.googleapis.com/gloo-mesh-enterprise/gloo-mesh-enterprise
helm repo update

kubectl create namespace gloo-mesh

# temporary
source ~/bin/gloo-mesh-license-env
helm install gloo-mesh-enterprise gloo-mesh-enterprise/gloo-mesh-enterprise -n gloo-mesh --set licenseKey=${GLOO_MESH_LICENSE} --version=0.3.2

kubectl --context $MGMT_CONTEXT -n gloo-mesh rollout status deploy/discovery 
kubectl --context $MGMT_CONTEXT -n gloo-mesh rollout status deploy/networking 
kubectl --context $MGMT_CONTEXT -n gloo-mesh rollout status rbac-webhook
kubectl --context $MGMT_CONTEXT -n gloo-mesh rollout status deploy/gloo-mesh-apiserver


kubectl port-forward -n gloo-mesh svc/gloo-mesh-console 8090  > /dev/null 2>&1 &
