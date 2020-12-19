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
helm install gloo-mesh-enterprise gloo-mesh-enterprise/gloo-mesh-enterprise -n gloo-mesh --set licenseKey=${GLOO_MESH_LICENSE} --version=0.4.0

kubectl --context $MGMT_CONTEXT -n gloo-mesh rollout status deploy/discovery 
kubectl --context $MGMT_CONTEXT -n gloo-mesh rollout status deploy/networking 
kubectl --context $MGMT_CONTEXT -n gloo-mesh rollout status deploy/rbac-webhook
kubectl --context $MGMT_CONTEXT -n gloo-mesh rollout status deploy/gloo-mesh-apiserver

# install clusterrole
kubectl apply -f user/clusterrolebinding.yaml

# creating users
echo "creating default users"
pushd ./user
. ./create-default-users.sh
popd ./user

kubectl port-forward -n gloo-mesh svc/gloo-mesh-console 8090  > /dev/null 2>&1 &
echo "Gloo Mesh read-only UI available on http://localhost:8090/"