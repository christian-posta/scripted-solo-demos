#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

SOURCE_DIR=$PWD
source env.sh
# get enterprise license
source ~/bin/gloo-mesh-license-env

kubectl config use-context $MGMT_CONTEXT
helm repo add gloo-mesh-enterprise https://storage.googleapis.com/gloo-mesh-enterprise/gloo-mesh-enterprise
helm repo update

# we may need a beta version?
# helm search repo gloo-mesh-enterprise --devel

kubectl create namespace gloo-mesh

# Helm Install
helm install gloo-mesh-enterprise gloo-mesh-enterprise/gloo-mesh-enterprise --kube-context $MGMT_CONTEXT -n gloo-mesh --version=1.1.0-beta9 --set licenseKey=${GLOO_MESH_LICENSE} --set rbac-webhook.enabled=true

# serviceType=LoadBalancer might be default now
# helm install gloo-mesh-enterprise gloo-mesh-enterprise/gloo-mesh-enterprise --kube-context $MGMT_CONTEXT -n gloo-mesh --version=1.1.0-beta9 --set licenseKey=${GLOO_MESH_LICENSE} --set enterprise-networking.enterpriseNetworking.serviceType=LoadBalancer 


kubectl --context $MGMT_CONTEXT -n gloo-mesh rollout status deploy/enterprise-networking 
kubectl --context $MGMT_CONTEXT -n gloo-mesh rollout status deploy/dashboard
kubectl --context $MGMT_CONTEXT -n gloo-mesh rollout status deploy/rbac-webhook

meshctl check

kubectl --context $MGMT_CONTEXT apply -f ./resources/admin-binding-ceposta.yaml

#kubectl port-forward -n gloo-mesh svc/dashboard 8090  > /dev/null 2>&1 &
#echo "Gloo Mesh read-only UI available on http://localhost:8090/"
