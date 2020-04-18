#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

SOURCE_DIR=$PWD

source env.sh

#############################################
# Discovery
#############################################

desc "Welcome to Serivce Mesh Hub demo!"
desc "Let's get started"
read -s

desc "We have installed istio onto two clustes:"
run "kubectl get po -n istio-system --context $CLUSTER_1 "
run "kubectl get po -n istio-system --context $CLUSTER_2"

desc "We also have bookinfo (v1 and v2 of reviews) on cluster 1"
run "kubectl get po -n default --context $CLUSTER_1 "

desc "And boookinfo reviews-v3 on cluster 2"
run "kubectl get po -n default --context $CLUSTER_2"

backtotop
desc "Let's install the SMH management plane onto cluster 1"
read -s

run "meshctl install --context $CLUSTER_1 "
run "kubectl get po -n service-mesh-hub -w"
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
desc "Right now, the two meshes have different root trusts"
read -s

desc "For example, when we look at cluster 1 and see the certs presented"
REVIEWS_POD=$(kubectl get po -n default -l app=reviews --context $CLUSTER_1 | grep -i running | head -n 1 | awk '{ print $1 }')
run "kubectl --context $CLUSTER_1 exec -it $REVIEWS_POD -c istio-proxy -- openssl s_client -showcerts -connect ratings.default:9080"


backtotop
desc "Let's see the same on cluster 2"
read -s

REVIEWS_POD=$(kubectl get po -n default -l app=reviews --context $CLUSTER_2 | grep -i running | head -n 1 | awk '{ print $1 }')
run "kubectl --context $CLUSTER_2 exec -it $REVIEWS_POD -c istio-proxy -- openssl s_client -showcerts -connect ratings.default:9080"

backtotop
desc "The VirtualMesh CRD allows us to federate the two meshes"
read -s

run "cat resources/virtual-mesh.yaml"
run "kubectl apply -f resources/virtual-mesh.yaml --context $CLUSTER_1"
run "kubectl get virtualmesh -n service-mesh-hub -o yaml --context $CLUSTER_1"

backtotop
desc "Let's watch what's happening... "
desc "We've now created a new Root CA, and initated intermediate CAs on each istio cluster"
read -s

# more suited for copy/paste
# kubectl get secret -n service-mesh-hub virtual-mesh-ca-certs  -o "jsonpath={.data['root-cert\.pem']}" --context $CLUSTER_1 | base64 --decode
desc "This is the root cert we created on the management plane"
run "kubectl get secret -n service-mesh-hub virtual-mesh-ca-certs  -o \"jsonpath={.data['root-cert\.pem']}\" --context $CLUSTER_1 | base64 --decode"

desc "The remote clusters created a CSR"
run "kubectl get virtualmeshcertificatesigningrequests -n service-mesh-hub --context $CLUSTER_2"

desc "If successfully signed, will be signed by the root cert"
run "kubectl get virtualmeshcertificatesigningrequests -n service-mesh-hub -o yaml --context $CLUSTER_2"

backtotop
desc "We've created the new CA for  istio"
read -s
run "kubectl get secret -n istio-system cacerts --context $CLUSTER_1"
run "kubectl get secret -n istio-system cacerts --context $CLUSTER_2"

desc "Bounce the istio pod (and workloads so they pick up the new cert)"
run "kubectl delete pod -n istio-system -l app=istiod --context $CLUSTER_1"
kubectl delete po --wait=false -n default --all --context $CLUSTER_1 > /dev/null 2>&1

run "kubectl delete pod -n istio-system -l app=istiod --context $CLUSTER_2"
kubectl delete po --wait=false -n default --all --context $CLUSTER_2 > /dev/null 2>&1

run "kubectl get po -n default -w --context $CLUSTER_1"

#Now check out the certs from the workloads
backtotop
desc "let's check the certs now in the workloads"
read -s

desc "Cert chain we see on cluster 1"
REVIEWS_POD=$(kubectl get po -n default -l app=reviews --context $CLUSTER_1 | grep -i running | head -n 1 | awk '{ print $1 }')
run "kubectl --context $CLUSTER_1 exec -it $REVIEWS_POD -c istio-proxy -- openssl s_client -showcerts -connect ratings.default:9080"

desc "Cert chain we see on cluster 2"
REVIEWS_POD=$(kubectl get po -n default -l app=reviews --context $CLUSTER_2 | grep -i running | head -n 1 | awk '{ print $1 }')
run "kubectl --context $CLUSTER_2 exec -it $REVIEWS_POD -c istio-proxy -- openssl s_client -showcerts -connect ratings.default:9080"

desc "We now have a common root of trust, with intermediates signed and no keys exchanging over the network"


#############################################
# Traffic Routing
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

desc "Let's port-forward the bookinfo demo so we can see its behavior"
tmux split-window -v -d -c $SOURCE_DIR
tmux select-pane -t 0
tmux send-keys -t 1 "kubectl port-forward deployments/productpage-v1 9080" C-m

run "cat resources/reviews-tp-c1-c2.yaml"
run "kubectl apply -f resources/reviews-tp-c1-c2.yaml --context $CLUSTER_1"
run "kubectl get virtualservice -A -o yaml --context $CLUSTER_1"

backtotop
desc "Let's see what rules are on the reviews service"
read -s
run "meshctl describe service reviews.default.cluster-1"