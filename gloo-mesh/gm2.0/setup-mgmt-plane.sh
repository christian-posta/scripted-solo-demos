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


helm install gloo-mesh-enterprise gloo-mesh-enterprise/gloo-mesh-enterprise --kube-context $MGMT_CONTEXT -n gloo-mesh --version=$GLOO_MESH_VERSION --set licenseKey=${GLOO_MESH_LICENSE} 


# register clusters
kubectl --context $MGMT_CONTEXT apply -f resources/kubernetes-cluster-1.yaml
kubectl --context $MGMT_CONTEXT apply -f resources/kubernetes-cluster-2.yaml