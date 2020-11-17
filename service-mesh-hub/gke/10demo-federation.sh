#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

SOURCE_DIR=$PWD
source env.sh

kubectl config use-context $MGMT_CONTEXT

desc "Let's see how easy it is to federate the two meshes"
read -s

backtotop
desc "Right now, the two meshes have different root trusts"
read -s

desc "There is no mTLS, we will need to add it"
REVIEWS_POD=$(kubectl get po -n default -l app=reviews --context $CLUSTER_1 | grep -i running | head -n 1 | awk '{ print $1 }')

run "kubectl --context $CLUSTER_1 exec -it $REVIEWS_POD -c istio-proxy -- openssl s_client -showcerts -connect ratings.default:9080"
run "kubectl apply -f resources/peerauth-strict.yaml --context $CLUSTER_1 "
run "kubectl apply -f resources/peerauth-strict.yaml --context $CLUSTER_2 "


##############################
# Check root chain on cluster 1
##############################

desc "Cert chain we see on cluster 1"
REVIEWS_POD=$(kubectl get po -n default -l app=reviews --context $CLUSTER_1 | grep -i running | head -n 1 | awk '{ print $1 }')
run "kubectl --context $CLUSTER_1 exec -it $REVIEWS_POD -c istio-proxy -- openssl s_client -showcerts -connect ratings.default:9080"

desc "Compare this to the CA cert in cluster 1's istio"
desc "They should be the same"
run "kubectl get secret -n istio-system istio-ca-secret -o \"jsonpath={.data['ca-cert\.pem']}\" --context $CLUSTER_1 | base64 --decode"


##############################
# Check root chain on cluster 2
##############################
backtotop
desc "Let's see the same on cluster 2"
read -s

desc "Cert chain we see on cluster 2"
REVIEWS_POD=$(kubectl get po -n default -l app=reviews --context $CLUSTER_2 | grep -i running | head -n 1 | awk '{ print $1 }')
run "kubectl --context $CLUSTER_2 exec -it $REVIEWS_POD -c istio-proxy -- openssl s_client -showcerts -connect ratings.default:9080"

desc "And compare to the CA cert on cluster 2"
run "kubectl get secret -n istio-system istio-ca-secret -o \"jsonpath={.data['ca-cert\.pem']}\" --context $CLUSTER_2 | base64 --decode"

desc "these are different between the two clusters!!"
read -s

##############################
# Federate the root certs
##############################

backtotop
desc "The VirtualMesh CRD allows us to federate the two meshes"
read -s

run "cat resources/virtual-mesh.yaml"
run "kubectl apply -f resources/virtual-mesh.yaml"
run "kubectl get virtualmesh -n gloo-mesh -o yaml"

backtotop
desc "We've now created a new Root CA, and initated intermediate CAs on each istio cluster"
read -s

##############################
# Check / Bounce Istio
##############################
backtotop
desc "We've created the new CA for istio"
read -s
run "kubectl get secret -n istio-system cacerts --context $CLUSTER_1"
run "kubectl get secret -n istio-system cacerts --context $CLUSTER_2"

kubectl --context $CLUSTER_1 -n istio-system delete pod -l app=istio-ingressgateway
kubectl --context $CLUSTER_2 -n istio-system delete pod -l app=istio-ingressgateway
kubectl delete po --wait=false -n default --all --context $CLUSTER_1 > /dev/null 2>&1
kubectl delete po --wait=false -n default --all --context $CLUSTER_2 > /dev/null 2>&1

run "kubectl get po -n default -w --context $CLUSTER_1"


##############################
# Check federated certs
##############################

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
desc "Next demo we look at utilizing this trust boundary"
