#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

SOURCE_DIR=$PWD
source env.sh


desc "Let's see how easy it is to federate the two meshes"
read -s

desc "We have installed istio onto two clustes:"
run "kubectl get po -n istio-system --context $CLUSTER_1 "
run "kubectl get po -n istio-system --context $CLUSTER_2"

backtotop
desc "Right now, the two meshes have different root trusts"
read -s

desc "For example, when we look at cluster 1 and see the certs presented"
run "kubectl --context $CLUSTER_1 exec -it $(kubectl --context $CLUSTER_1 get po -l app=reviews -o jsonpath={.items..metadata.name}|awk '{ print $1 }') -c istio-proxy -- openssl s_client -showcerts -connect ratings.default:9080"

desc "Compare this to the CA cert in cluster 1's istio"
desc "They should be the same"
run "kubectl get secret -n istio-system istio-ca-secret -o \"jsonpath={.data['ca-cert\.pem']}\" --context $CLUSTER_1 | base64 --decode"


backtotop
desc "Let's see the same on cluster 2"
read -s

run "kubectl --context $CLUSTER_2 exec -it $(kubectl --context $CLUSTER_2 get po -l app=reviews -o jsonpath={.items..metadata.name} |awk '{ print $1 }') -c istio-proxy -- openssl s_client -showcerts -connect ratings.default:9080"

desc "And compare to the CA cert on cluster 2"
run "kubectl get secret -n istio-system istio-ca-secret -o \"jsonpath={.data['ca-cert\.pem']}\" --context $CLUSTER_2 | base64 --decode"

desc "these are different between the two clusters!!"
read -s

backtotop
desc "The VirtualMesh CRD allows us to federate the two meshes"
read -s

run "cat resources/virtual-mesh.yaml"
run "kubectl --context $CLUSTER_1 apply -f resources/virtual-mesh.yaml"
run "kubectl --context $CLUSTER_1 get virtualmesh -n service-mesh-hub -o yaml"

backtotop
desc "Let's watch what's happening... "
desc "We've now created a new Root CA, and initated intermediate CAs on each istio cluster"
read -s

run "kubectl get virtualmeshcertificatesigningrequests -n service-mesh-hub --context $CLUSTER_1"
run "kubectl get virtualmeshcertificatesigningrequests -n service-mesh-hub --context $CLUSTER_2"
run "kubectl get virtualmeshcertificatesigningrequests -n service-mesh-hub -o yaml --context $CLUSTER_2"

run "kubectl get secret -n service-mesh-hub"

desc "this is the root cert we created for SMH"
run "kubectl get secret -n service-mesh-hub virtual-mesh-ca-certs  -o \"jsonpath={.data['root-cert\.pem']}\" --context $CLUSTER_1 | base64 --decode"

desc "Copy this cert so we can compare"
read -s

backtotop
desc "this is the root cert used to sign handle the CSR"
read -s

run "kubectl get virtualmeshcertificatesigningrequests  -n service-mesh-hub -o \"jsonpath={.items[0].status.response.rootCertificate}\" --context $CLUSTER_2 | base64 --decode"

backtotop
desc "We've created the new CA for  istio"
read -s
run "kubectl --context $CLUSTER_1 get secret -n istio-system cacerts"
run "kubectl --context $CLUSTER_2 get secret -n istio-system cacerts"

desc "Looking at the root cert from the cacerts intermediate chain"
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

run "kubectl get po -n default -w --cluster $CLUSTER_1"

run "kubectl --context $CLUSTER_1 exec -it $(kubectl --context $CLUSTER_1 get po -l app=reviews -o jsonpath={.items..metadata.name}|awk '{ print $1 }') -c istio-proxy -- openssl s_client -showcerts -connect ratings.default:9080"

desc "We now have a common root of trust, with intermediates signed and no keys exchanging over the network"
desc "Next demo we look at utilizing this trust boundary"
