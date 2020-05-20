#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD
source env.sh


desc "We have kubefed control plane installed on cluster 1"
run "kubectl get po -n kube-federation-system --context $CLUSTER_1"

backtotop
desc "Now let's register Kubernetes clusters with the control plane"
read -s
run "kubefedctl join cluster1 --cluster-context cluster1 --host-cluster-context cluster1 --v 2"
run "kubefedctl join cluster2 --cluster-context cluster2 --host-cluster-context cluster1 --v 2"

## this needs to happen on a mac
./resources/fix-joined-kind-clusters.sh > /dev/null 2>&1

run "kubectl get kubefedclusters -A -o yaml"

