#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD

desc "Quick Lattice Demo for AWS Community Day"
read -s


inventoryFQDN=$(kubectl --context ceposta-eks-1 get httproute inventory -o json | jq -r '.metadata.annotations."application-networking.k8s.aws/lattice-assigned-domain-name"')


run "kubectl --context ceposta-eks-1 exec deploy/parking -- bash -c 'for ((i=1; i<=30; i++)); do curl -s \"$inventoryFQDN\"; done' "

