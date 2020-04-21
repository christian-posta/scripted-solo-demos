#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

SOURCE_DIR=$PWD
source env.sh

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
desc "Let's install the SMH management plane onto cluster 1"
read -s

run "meshctl install --context $CLUSTER_1 "
run "kubectl get po -n service-mesh-hub -w --context $CLUSTER_1 "
run "meshctl check --context $CLUSTER_1"

backtotop
desc "Now that we've got the management plane installed, let's see what we're working with"
read -s

run "kubectl get kubernetesclusters -n service-mesh-hub --context $CLUSTER_1"
desc "We don't have any clusters..."
desc "... or meshes"
run "kubectl get meshes -n service-mesh-hub --context $CLUSTER_1"

##############################
# Register some clusters
##############################
backtotop
desc "Let's register our two clusters"
read -s

run "meshctl cluster register --remote-context $CLUSTER_1 --remote-cluster-name cluster-1"
run "meshctl cluster register --remote-context $CLUSTER_2 --remote-cluster-name cluster-2 "


##############################
# View discovered resources
##############################
desc "Now we should have discovered the meshes"
run "kubectl get kubernetesclusters -n service-mesh-hub --context $CLUSTER_1"
run "kubectl get meshes -n service-mesh-hub --context $CLUSTER_1"

desc "We've discovered all of the services"
run "kubectl get meshservices -A"
run "kubectl get meshservices reviews-default-cluster-1 -o yaml -n service-mesh-hub --context $CLUSTER_1"

desc "We've discovered all of the workload instances"
run "kubectl get meshworkloads -A"
run "kubectl get meshworkloads istio-reviews-v3-default-cluster-2 -o yaml -n service-mesh-hub --context $CLUSTER_1"

desc "Now let's look at federating the clusters"

