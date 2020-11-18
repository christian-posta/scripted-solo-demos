#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

SOURCE_DIR=$PWD
source env.sh

kubectl config use-context $MGMT_CONTEXT

desc "Welcome to Serivce Mesh Hub demo!"
desc "Let's get started"
read -s

##############################
# Check our environemnt
##############################
desc "We have installed istio onto two clustes:"
run "kubectl get po -n istio-system --context $CLUSTER_1 "
run "kubectl get po -n istio-system --context $CLUSTER_2"

desc "We also have bookinfo (v1 and v2 of reviews) on cluster 1"
run "kubectl get po -n default --context $CLUSTER_1 "

desc "And boookinfo reviews-v3 on cluster 2"
run "kubectl get po -n default --context $CLUSTER_2"

##############################
# Install SMH
##############################
backtotop
desc "Let's see what we're working with"
read -s

run "kubectl get kubernetesclusters -n gloo-mesh"
desc "We don't have any clusters..."
desc "... or meshes"
run "kubectl get meshes -n gloo-mesh"

##############################
# Register some clusters
##############################
backtotop
desc "Let's register our two clusters"
read -s

run "meshctl cluster register --cluster-name cluster-1 --remote-context $CLUSTER_1 --mgmt-context $MGMT_CONTEXT"

run "meshctl cluster register --cluster-name cluster-2 --remote-context $CLUSTER_2 --mgmt-context $MGMT_CONTEXT"


##############################
# View discovered resources
##############################
desc "Now we should have discovered the meshes"
run "kubectl get kubernetesclusters -n gloo-mesh"
run "kubectl get meshes -n gloo-mesh"
run "kubectl get workloads -n gloo-mesh"

desc "Now let's look at federating the clusters"

