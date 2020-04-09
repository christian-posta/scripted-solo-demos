#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD
source env-kind.sh

desc "We've installed SMH successfully"
run "meshctl check"

backtotop

desc "We've got istio installed in two different clusters"
read -s

run "kubectl --context $CLUSTER_1 get po -n istio-system"
run "kubectl --context $CLUSTER_2 get po -n istio-system"

backtotop
desc "SMH can do detection of service meshes in your clusters"
read -s

desc "Right now we have only one cluster (the management plane) and one mesh"
run "kubectl get kubernetesclusters -n service-mesh-hub"
run "kubectl get meshes -n service-mesh-hub"

desc "Let's register our second clusters"
run "meshctl cluster register --remote-context $CLUSTER_2 --remote-cluster-name remote-cluster"

desc "We have two different clusters"
run "kubectl get kubernetesclusters -n service-mesh-hub"

desc "We've automatically discovered two Istio meshes"
run "kubectl get meshes -n service-mesh-hub"

backtotop

desc "We have workloads running in cluster one:"
read -s

run "kubectl --context $CLUSTER_1 get po -n default"

desc "We also have some other workloads in cluster two"
run "kubectl --context $CLUSTER_2 get po -n default"

desc "Let's group these two separate istio meshes into one single mesh that we can treat atomically"
backtotop

desc "Let's review our VirtualMesh"
read -s

run "cat $(relative resources/virtual-mesh-cluster1-2.yaml)"

exit


# check the cert signing stuff
#kubectl get virtualmeshcertificatesigningrequests -A

#kubectl delete pod -n service-mesh-hub -l service-mesh-hub=mesh-networking --context $CLUSTER_1
#kubectl delete pod -n service-mesh-hub -l service-mesh-hub=mesh-networking --context $CLUSTER_2

#kubectl delete pod -n istio-system -l app=istiod --context $CLUSTER_1
#kubectl delete pod -n istio-system -l app=istiod --context $CLUSTER_2



