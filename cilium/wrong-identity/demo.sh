#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh
SOURCE_DIR=$PWD


pod=$(kubectl -n kube-system get pods -l k8s-app=cilium -o jsonpath='{.items[0].metadata.name}')


backtotop
desc "-----==== Understanding identity in Cilium ====-----"
read -s


desc "We have v1 and v2 of each sleep and helloworld services"
run "kubectl get po -n default"

desc "We only want sleep-v1 to call helloworld-v1"
desc "and sleep-v2 to call helloworld-v2"
desc "We CANNOT allow sleep-v2 to call helloworld-v1, it"
desc "would be a regulatory violation in our demo"
read -s


backtotop
desc "*** Set up network policy to enforce our policies ***"
read -s

run "cat ./resources/helloworld-v1-policy.yaml"
run "kubectl apply -f ./resources/helloworld-v1-policy.yaml"

run "cat ./resources/helloworld-v2-policy.yaml"
run "kubectl apply -f ./resources/helloworld-v2-policy.yaml"

desc "Verify that only v1 to v1 traffic is allowed and no other"
run "./call-combinations.sh"


desc "Note the network policy is enforced!"
read -s

backtotop
desc "*** Check the cilium identities ***"
read -s

run "kubectl get ciliumidentities | grep default"

desc "Lets take a look at the identity representing sleep-v1"

run "kubectl get ciliumendpoints.cilium.io -l app=sleep,version=v1 -o jsonpath='{.items[0].status.identity.id}'"

IDENTITY_ID=$(kubectl get ciliumendpoints.cilium.io -l app=sleep,version=v1 -o jsonpath='{.items[0].status.identity.id}')

run "kubectl get ciliumidentity $IDENTITY_ID -o yaml"

run "kubectl exec -n kube-system ds/cilium -c cilium-agent -- cilium map get cilium_ipcache | grep $IDENTITY_ID"

backtotop
desc "*** Can this identity mapping get confused? ***"
read -s

