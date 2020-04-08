#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD

desc "Welcome to service mesh hub!"
desc "Let's take a look at the easiest way to get started with multi-cluster service mesh / Istio"
#run "meshctl demo istio-multicluster --use-kind"
run "meshctl demo init"

desc "This set up two clusters for us in kind"
run "kind get clusters"

desc "Let's check that SMH was successfully installed"
run "meshctl check"

source env-kind.sh

backtotop

desc "We've got istio installed in two different clusters"
read -s

run "kubectl --context $CLUSTER_1 get po -n istio-system"
run "kubectl --context $CLUSTER_2 get po -n istio-system"

backtotop
desc "SMH can do detection of service meshes in your clusters"
read -s

desc "We have two different clusters"
run "kubectl get kubernetesclusters -n service-mesh-hub"

desc "We could register other clusters"
run "meshctl cluster register --help"

desc "We've automatically discovered two Istio meshes"
run "kubectl get meshes -n service-mesh-hub"

backtotop

desc "Let's install bookinfo on cluster 1"
read -s

run "kubectl --context $CLUSTER_1 label namespace default istio-injection=enabled"
run "kubectl --context $CLUSTER_1 apply -f resources/bookinfo-cluster1.yaml"
run "kubectl --context $CLUSTER_1 get po -n default -w"

desc "Let's port-forward the bookinfo demo so we can see its behavior"
tmux split-window -v -d -c $SOURCE_DIR
tmux select-pane -t 0
tmux send-keys -t 1 "kubectl port-forward deployments/productpage-v1 9080" C-m


desc "Go check out the productpage in a browser"
read -s


desc "Let's install reviews-v3 on cluster 2"
read -s

run "kubectl --context $CLUSTER_2 label namespace default istio-injection=enabled"
run "kubectl --context $CLUSTER_2 apply -f resources/bookinfo-cluster2.yaml"
run "kubectl --context $CLUSTER_2 get po -n default -w"

desc "Now let's group these two different meshes so we can treat it as a single federated mesh"
backtotop

desc "Let's review our VirtualMesh"
read -s

run "cat $(relative resources/virtual-mesh-cluster1-2-no-rbac.yaml)"
backtotop

read -s

desc "Let's apply this VirtualMesh"
run "kubectl --context $CLUSTER_1 apply -f resources/virtual-mesh-cluster1-2-no-rbac.yaml"

desc "Let's verify the CSR was created for the Istio CA"
run "kubectl --context $CLUSTER_1 get virtualmeshcertificatesigningrequests -n service-mesh-hub"
run "kubectl --context $CLUSTER_2 get virtualmeshcertificatesigningrequests -n service-mesh-hub"

desc "Let's the cacerts were created"
run "kubectl --context $CLUSTER_1 get secret -n istio-system cacerts"
run "kubectl --context $CLUSTER_2 get secret -n istio-system cacerts"

desc "We have to bounce the istio pod to correctly pick up the new certificate"
run "kubectl delete pod -n istio-system -l app=istiod --context $CLUSTER_1"
# Also delete the SMH pods to work around pre-release bug << don't need this anymore, but keeping
# it here as a comment just in case
kubectl delete --wait=false pod -n service-mesh-hub -l service-mesh-hub=mesh-networking --context $CLUSTER_1 > /dev/null 2>&1

# delete the workloads also so they pick up the new certs
kubectl delete --wait=false -n default po --all --context $CLUSTER_1 > /dev/null 2>&1

run "kubectl delete pod -n istio-system -l app=istiod --context $CLUSTER_2"

# delete the workloads also so they pick up the new certs
kubectl delete --wait=false -n default po --all --context $CLUSTER_2 > /dev/null 2>&1

backtotop
desc "Show some of the underlying Istio objects automatically created"
read -s
run "kubectl get serviceentry -A"

backtotop
desc "Now let's route traffic between clusters"
read -s

run "cat resources/cross-cluster-traffic-policy.yaml"
run "kubectl apply -f resources/cross-cluster-traffic-policy.yaml"
run "kubectl get virtualservice -A"
run "kubectl get virtualservice -A -o yaml"

backtotop
desc "Now time to clean up"
read -s
tmux send-keys -t 1 C-c
tmux send-keys -t 1 "exit" C-m

run "meshctl demo cleanup"
#run "./cleanup-kind.sh"

## Useful debugging
## kubectl exec -it $(kubectl get po -l app=productpage -o jsonpath={.items..metadata.name}) -c istio-proxy -- openssl s_client -showcerts -connect reviews.default:9080