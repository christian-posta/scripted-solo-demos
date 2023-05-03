#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh
SOURCE_DIR=$PWD


pod=$(kubectl -n kube-system get pods -l k8s-app=cilium -o jsonpath='{.items[0].metadata.name}')


backtotop
desc "-----==== Digging into Cilium Ingress support ====-----"
read -s

desc "Take a look at an ingress resource"
run "cat ./resources/details-ingress.yaml"
run "kubectl apply -f ./resources/details-ingress.yaml"
