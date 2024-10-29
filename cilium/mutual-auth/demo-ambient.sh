#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh
SOURCE_DIR=$PWD


pod=$(kubectl -n kube-system get pods -l k8s-app=cilium -o jsonpath='{.items[0].metadata.name}')


backtotop
desc "Enable Istio"
read -s

# add services to ambient
run "kubectl label namespace default istio.io/dataplane-mode=ambient"

desc "The services are now in the mesh! Go check it out"
read -s


backtotop
desc "Let's add some mesh policy"
-s 


run "cat istio/policy-deny-all.yaml"
run "cat istio/policy-authz.yaml"
run "kubectl apply -f istio/policy-deny-all.yaml"
run "kubectl apply -f istio/policy-authz.yaml"

desc "now go run the mistaken identity"




