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

# Helm Install GM
helm install gloo-mesh-enterprise gloo-mesh-enterprise/gloo-mesh-enterprise --kube-context $MGMT_CONTEXT -n gloo-mesh --version=1.1.0-beta9 --set licenseKey=${GLOO_MESH_LICENSE} --set rbac-webhook.enabled=true

# serviceType=LoadBalancer might be default now
# helm install gloo-mesh-enterprise gloo-mesh-enterprise/gloo-mesh-enterprise --kube-context $MGMT_CONTEXT -n gloo-mesh --version=1.1.0-beta9 --set licenseKey=${GLOO_MESH_LICENSE} --set enterprise-networking.enterpriseNetworking.serviceType=LoadBalancer 


kubectl --context $MGMT_CONTEXT -n gloo-mesh rollout status deploy/enterprise-networking 
kubectl --context $MGMT_CONTEXT -n gloo-mesh rollout status deploy/dashboard
kubectl --context $MGMT_CONTEXT -n gloo-mesh rollout status deploy/rbac-webhook

kubectl --context $MGMT_CONTEXT apply -f ./resources/admin-binding-ceposta.yaml
meshctl check

## Let's install Gloo Edge to expose argo/gogs
source ~/bin/gloo-license-key-env 
helm install gloo-edge glooe/gloo-ee --kube-context $MGMT_CONTEXT -f ./gloo/values-mgmtplane.yaml --version 1.7.7 --create-namespace --namespace gloo-system --set gloo.crds.create=true --set-string license_key=$GLOO_LICENSE

kubectl --context $MGMT_CONTEXT apply -f ./resources/gloo-ingress/gloo-mesh-ui-us.yaml
kubectl --context $MGMT_CONTEXT apply -f ./resources/gloo-ingress/gloo-mesh-ui-vs.yaml
echo "Gloo Mesh read-only UI available on http://dashboard.mesh.ceposta.solo.io/"

#kubectl port-forward -n gloo-mesh svc/dashboard 8090  > /dev/null 2>&1 &
#echo "Gloo Mesh read-only UI available on http://localhost:8090/"
