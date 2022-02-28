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


# Helm Install GM
if [ "$USING_KIND" == "true" ] ; then
    helm install gloo-mesh-enterprise gloo-mesh-enterprise/gloo-mesh-enterprise --kube-context $MGMT_CONTEXT -n gloo-mesh --version=$GLOO_MESH_VERSION --set licenseKey=${GLOO_MESH_LICENSE} -f ./resources/gloo-mesh-install/values-kind.yaml
else
    helm install gloo-mesh-enterprise gloo-mesh-enterprise/gloo-mesh-enterprise --kube-context $MGMT_CONTEXT -n gloo-mesh --version=$GLOO_MESH_VERSION --set licenseKey=${GLOO_MESH_LICENSE} -f ./resources/gloo-mesh-install/values.yaml
fi

# wait for core services to come up...

kubectl --context $MGMT_CONTEXT -n gloo-mesh rollout status deploy/gloo-mesh-mgmt-server
kubectl --context $MGMT_CONTEXT -n gloo-mesh rollout status deploy/gloo-mesh-ui
kubectl --context $MGMT_CONTEXT -n gloo-mesh rollout status deploy/gloo-mesh-redis 
kubectl --context $MGMT_CONTEXT -n gloo-mesh rollout status deploy/prometheus-server


# specify clusters
kubectl --context $MGMT_CONTEXT apply -f resources/kubernetes-cluster-1.yaml
kubectl --context $MGMT_CONTEXT apply -f resources/kubernetes-cluster-2.yaml

## Let's install Gloo Edge to expose argo/gogs
source ~/bin/gloo-license-key-env 
helm repo add glooe http://storage.googleapis.com/gloo-ee-helm
helm repo update

if [ "$USING_KIND" == "true" ] ; then
    helm install gloo-edge glooe/gloo-ee --kube-context $MGMT_CONTEXT -f ./resources/gloo/values-mgmtplane-kind.yaml --version 1.7.7 --create-namespace --namespace gloo-system --set gloo.crds.create=true --set istiodSidecar.createRoleBinding=true --set-string license_key=$GLOO_LICENSE

else 
    helm install gloo-edge glooe/gloo-ee --kube-context $MGMT_CONTEXT -f ./resources/gloo/values-mgmtplane.yaml --version 1.7.7 --create-namespace --namespace gloo-system --set gloo.crds.create=true --set istiodSidecar.createRoleBinding=true --set-string license_key=$GLOO_LICENSE
fi

kubectl --context $MGMT_CONTEXT -n gloo-system rollout status deploy/gloo

kubectl --context $MGMT_CONTEXT apply -f ./resources/gloo/gloo-mesh-ui-us.yaml
kubectl --context $MGMT_CONTEXT apply -f ./resources/gloo/gloo-mesh-ui-vs.yaml

echo "Gloo Mesh read-only UI available on http://dashboard.gloo-mesh.istiodemos.io/"

## set up gateway workspace root config
kubectl create namespace gloo-mesh-gateway

