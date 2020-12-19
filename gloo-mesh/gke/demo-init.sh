#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

SOURCE_DIR=$PWD

source env.sh
kubectl config use-context $MGMT_CONTEXT

# EKS-d running locally needs to be registered with host.docker.internal
meshctl cluster register --cluster-name $CLUSTER_1_NAME --remote-context $CLUSTER_1 --mgmt-context $MGMT_CONTEXT

meshctl cluster register --cluster-name $CLUSTER_2_NAME --remote-context $CLUSTER_2 --mgmt-context $MGMT_CONTEXT

kubectl apply -f resources/peerauth-strict.yaml --context $CLUSTER_1 > /dev/null 2>&1
kubectl apply -f resources/peerauth-strict.yaml --context $CLUSTER_2 > /dev/null 2>&1

kubectl apply -f resources/virtual-mesh.yaml

. ./check-virtualmesh.sh
echo "preparing to restart pods..."
sleep 5s

kubectl delete po --wait=false -n default --all --context $CLUSTER_1 > /dev/null 2>&1
kubectl delete po --wait=false -n default --all --context $CLUSTER_2 > /dev/null 2>&1

kubectl --context $CLUSTER_1 -n istio-system delete pod -l app=istio-ingressgateway > /dev/null 2>&1
kubectl --context $CLUSTER_2 -n istio-system delete pod -l app=istio-ingressgateway > /dev/null 2>&1

run "kubectl get po -n default -w --context $CLUSTER_1"