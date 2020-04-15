#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

SOURCE_DIR=$PWD
source env.sh


desc "Let's see how easy it is to federate the two meshes"
read -s

desc "We have installed istio onto two clustes:"
run "kubectl get po -n istio-system --context $CLUSTER_1 "
run "kubectl get po -n istio-system --context $CLUSTER_2"
run "kubectl get kubernetesclusters -n service-mesh-hub --context $CLUSTER_1"
run "kubectl get meshes -n service-mesh-hub --context $CLUSTER_1"

backtotop
desc "Right now, the two meshes have different root trusts"
read -s

desc "Cert chain we see on cluster 1"
REVIEWS_POD=$(kubectl get po -n default -l app=reviews --context $CLUSTER_1 | grep -i running | head -n 1 | awk '{ print $1 }')
run "kubectl --context $CLUSTER_1 exec -it $REVIEWS_POD -c istio-proxy -- openssl s_client -showcerts -connect ratings.default:9080"

desc "Compare this to the CA cert in cluster 1's istio"
desc "They should be the same"
run "kubectl get secret -n istio-system istio-ca-secret -o \"jsonpath={.data['ca-cert\.pem']}\" --context $CLUSTER_1 | base64 --decode"


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

desc "Let's look at the root cert that was created on the SMH management plane cluster"
run "kubectl get secret -n service-mesh-hub"

# more suited for copy/paste
# kubectl get secret -n service-mesh-hub virtual-mesh-ca-certs  -o "jsonpath={.data['root-cert\.pem']}" --context $CLUSTER_1 | base64 --decode
run "kubectl get secret -n service-mesh-hub virtual-mesh-ca-certs  -o \"jsonpath={.data['root-cert\.pem']}\" --context $CLUSTER_1 | base64 --decode"

desc "Copy this cert so we can compare"
read -s

backtotop
desc "We've created the CSR to establish the same root without exchanging keys over the network"
read -s

run "kubectl get virtualmeshcertificatesigningrequests -n service-mesh-hub --context $CLUSTER_2"
run "kubectl get virtualmeshcertificatesigningrequests -n service-mesh-hub -o yaml --context $CLUSTER_2"

#backtotop
#desc "Let's take a quick look at this CSR"
#read -s

#run "kubectl get virtualmeshcertificatesigningrequests -n service-mesh-hub -o yaml --context gke-istio-cluster-2   -o \"jsonpath={.items[].spec.csrData}\" --context $CLUSTER_2| base64 --decode > ./temp/cluster-2.csr"
#run "openssl req -in ./temp/cluster-2.csr -noout -text"


#backtotop
#desc "this is the root cert used to sign the CSR"
#read -s

#kubectl get virtualmeshcertificatesigningrequests  -n service-mesh-hub -o "jsonpath={.items[0].status.response.rootCertificate}" --context $CLUSTER_2 | base64 --decode

#run "kubectl get virtualmeshcertificatesigningrequests  -n service-mesh-hub -o \"jsonpath={.items[0].status.response.rootCertificate}\" --context $CLUSTER_2 | base64 --decode"

backtotop
desc "We've created the new CA for istio"
read -s
run "kubectl get secret -n istio-system cacerts --context $CLUSTER_1"
run "kubectl get secret -n istio-system cacerts --context $CLUSTER_2"

desc "Looking at the root cert from the cacerts intermediate chain"
#kubectl get secret cacerts -n istio-system -o "jsonpath={.data['root-cert\.pem']}" --context $CLUSTER_2| base64 --decode
run "kubectl get secret cacerts -n istio-system -o \"jsonpath={.data['root-cert\.pem']}\" --context $CLUSTER_2| base64 --decode"

desc "Bounce the istio pod (and workloads so they pick up the new cert)"
run "kubectl delete pod -n istio-system -l app=istiod --context $CLUSTER_1"
kubectl delete po --wait=false -n default --all --context $CLUSTER_1 > /dev/null 2>&1

run "kubectl delete pod -n istio-system -l app=istiod --context $CLUSTER_2"
kubectl delete po --wait=false -n default --all --context $CLUSTER_2 > /dev/null 2>&1

#Now check out the certs from the workloads
backtotop
desc "let's check the certs now in the workloads"
read -s

run "kubectl get po -n default -w --context $CLUSTER_1"

desc "Cert chain we see on cluster 1"
REVIEWS_POD=$(kubectl get po -n default -l app=reviews --context $CLUSTER_1 | grep -i running | head -n 1 | awk '{ print $1 }')
run "kubectl --context $CLUSTER_1 exec -it $REVIEWS_POD -c istio-proxy -- openssl s_client -showcerts -connect ratings.default:9080"

desc "Cert chain we see on cluster 2"
REVIEWS_POD=$(kubectl get po -n default -l app=reviews --context $CLUSTER_2 | grep -i running | head -n 1 | awk '{ print $1 }')
run "kubectl --context $CLUSTER_2 exec -it $REVIEWS_POD -c istio-proxy -- openssl s_client -showcerts -connect ratings.default:9080"

desc "We now have a common root of trust, with intermediates signed and no keys exchanging over the network"
desc "Next demo we look at utilizing this trust boundary"
