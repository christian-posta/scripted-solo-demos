#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

SOURCE_DIR=$PWD

source env.sh



#############################################
# Discovery
#############################################

backtotop
desc "Let's install the SMH management plane onto cluster 1"
read -s

run "meshctl install --context $CLUSTER_1 "
run "kubectl get po -n service-mesh-hub -w --context $CLUSTER_1 "
run "meshctl check --context $CLUSTER_1"

backtotop
desc "Let's register our two clusters"
read -s

run "meshctl cluster register --remote-context $CLUSTER_1 --remote-cluster-name cluster-1"
run "meshctl cluster register --remote-context $CLUSTER_2 --remote-cluster-name cluster-2 "

desc "Now we should have discovered the meshes"
run "kubectl get kubernetesclusters -n service-mesh-hub --context $CLUSTER_1"
run "kubectl get meshes -n service-mesh-hub --context $CLUSTER_1"

desc "Let's see how easy it is to federate the two meshes"
read -s

#############################################
# Trust Federation
#############################################

backtotop
desc "The VirtualMesh CRD allows us to federate the two meshes"
read -s

run "cat resources/virtual-mesh.yaml"
run "kubectl apply -f resources/virtual-mesh.yaml --context $CLUSTER_1"

desc "What happened was..."
read -s

run "kubectl get virtualmesh -n service-mesh-hub -o yaml --context $CLUSTER_1"

desc "Wait a moment to let the control plane converge on its new config..."
#Bounce the istio pod (and workloads so they pick up the new cert)
kubectl delete po --wait=false -n istio-system -l app=istiod --context $CLUSTER_1 > /dev/null 2>&1
kubectl delete po --wait=false -n default --all --context $CLUSTER_1 > /dev/null 2>&1

kubectl delete po --wait=false -n istio-system -l app=istiod --context $CLUSTER_2 > /dev/null 2>&1
kubectl delete po --wait=false -n default --all --context $CLUSTER_2 > /dev/null 2>&1


#############################################
# Traffic shifting
#############################################




backtotop
desc "Using this federated mesh, we can do things like control the traffic routing "
read -s

desc "The underlying Istio objects automatically created"
run "kubectl get serviceentry -A --context $CLUSTER_1"
run "kubectl get serviceentry -A --context $CLUSTER_2"

backtotop
desc "Let's look at the traffic routing API"
read -s

run "cat resources/reviews-tp-c1-c2.yaml"
run "kubectl apply -f resources/reviews-tp-c1-c2.yaml --context $CLUSTER_1"
run "kubectl get virtualservice -A -o yaml --context $CLUSTER_1"

backtotop
desc "Let's see what rules are on the reviews service"
read -s
run "meshctl describe service reviews.default.cluster-1"