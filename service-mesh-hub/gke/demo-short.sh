#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

SOURCE_DIR=$PWD

source env.sh


echo "Make sure management plane cluster is up"
read -s

kubectl config use-context $MGMT_CONTEXT

backtotop
desc "Let's install the SMH management plane onto a separate cluster"
read -s

run "meshctl install"
run "kubectl get po -n service-mesh-hub -w"
run "meshctl check"

backtotop
desc "Let's register our two clusters"
read -s

run "meshctl cluster register --cluster-name cluster-1 --remote-context $CLUSTER_1 --mgmt-context $MGMT_CONTEXT"

run "meshctl cluster register --cluster-name cluster-2 --remote-context $CLUSTER_2 --mgmt-context $MGMT_CONTEXT"

#############################################
# Trust Federation
#############################################

kubectl apply -f resources/peerauth-strict.yaml --context $CLUSTER_1
kubectl apply -f resources/peerauth-strict.yaml --context $CLUSTER_2

backtotop
desc "Right now, the two meshes have different root trusts"
read -s


backtotop
desc "The VirtualMesh CRD allows us to federate  and unify the two meshes"
read -s

run "cat resources/virtual-mesh.yaml"
run "kubectl apply -f resources/virtual-mesh.yaml"
run "kubectl get virtualmesh -n service-mesh-hub -o yaml"

backtotop
desc "We've now created a new Root CA, and initated intermediate CAs on each cluster"
read -s

run "kubectl get secret -n istio-system cacerts --context $CLUSTER_1"
run "kubectl get secret -n istio-system cacerts --context $CLUSTER_2"

kubectl --context cluster1 -n istio-system delete pod -l app=istio-ingressgateway
kubectl --context cluster2 -n istio-system delete pod -l app=istio-ingressgateway
kubectl delete po --wait=false -n default --all --context $CLUSTER_1 > /dev/null 2>&1
kubectl delete po --wait=false -n default --all --context $CLUSTER_2 > /dev/null 2>&1

run "kubectl get po -n default -w --context $CLUSTER_1"


#############################################
# Traffic Routing
#############################################
backtotop
desc "Now let's route reviews traffic to balance between cluster 1 and 2"
read -s

run "cat resources/reviews-tp-c1-c2.yaml"
run "kubectl apply -f resources/reviews-tp-c1-c2.yaml"
run "kubectl get virtualservice -A --context $CLUSTER_1"
run "kubectl get virtualservice -A -o yaml --context $CLUSTER_1"


#############################################
# Traffic Failover
#############################################
desc "In the previous demos, we federated the meshes and enabled access"
desc "In this demo, we'll explore how to declare failover behavior"
read -s

# Delete traffic policy
desc "Let's demonstrate failover between clusters"
run "kubectl delete TrafficPolicy reviews-tp -n service-mesh-hub"

desc "Next we need to add passive health checking to determine health and when to failover"
run "cat resources/reviews-outlier-tp.yaml"
run "kubectl apply -f resources/reviews-outlier-tp.yaml"


backtotop
desc "Now that we've defined health checking, let's see how to specify failover:"
read -s

run "cat resources/reviews-failover.yaml"
run "kubectl apply -f resources/reviews-failover.yaml"

run "cat resources/reviews-failover-tp.yaml"
run "kubectl apply -f resources/reviews-failover-tp.yaml"

backtotop
desc "To test it, let's make the reviews service (v1, v2) unhealthy on cluster-1"
read -s

run "kubectl --context $CLUSTER_1 patch deploy reviews-v1 --patch '{\"spec\": {\"template\": {\"spec\": {\"containers\": [{\"name\": \"reviews\",\"command\": [\"sleep\", \"20h\"]}]}}}}'"
run "kubectl --context $CLUSTER_1 patch deploy reviews-v2 --patch '{\"spec\": {\"template\": {\"spec\": {\"containers\": [{\"name\": \"reviews\",\"command\": [\"sleep\", \"20h\"]}]}}}}'"


# watch the logs in other cluster
run "kubectl --context $CLUSTER_2 logs -l app=reviews -c istio-proxy -f"

desc "You can also see all of this in the UI!"
read -s