#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD

desc "Quick Lattice Demo for AWS Community Day"
read -s

run "kubectl --context ceposta-eks-1 get po -n default"
run "kubectl --context ceposta-eks-1 get gateway,httproute"
run "kubectl --context ceposta-eks-1 get httproute inventory -o yaml"


inventoryFQDN=$(kubectl --context ceposta-eks-1 get httproute inventory -o json | jq -r '.metadata.annotations."application-networking.k8s.aws/lattice-assigned-domain-name"')


#run "kubectl --context ceposta-eks-1 exec deploy/parking -- curl -s $inventoryFQDN"
run "kubectl --context ceposta-eks-1 exec deploy/parking -- bash -c 'for ((i=1; i<=15; i++)); do curl -s \"$inventoryFQDN\"; done' "

run "kubectl --context ceposta-eks-2 get po -n default"


run "kubectl --context ceposta-eks-1 apply -f resources/inventory-ver2-import.yaml"
run "cat resources/inventory-route-bluegreen.yaml"
run "kubectl --context ceposta-eks-1 apply -f resources/inventory-route-bluegreen.yaml"

#inventoryFQDN=$(kubectl --context ceposta-eks-1 get httproute inventory -o json | jq -r '.metadata.annotations."application-networking.k8s.aws/lattice-assigned-domain-name"')

# Unescaped version:
#kubectl --context ceposta-eks-1 exec deploy/parking -- sh -c 'for ((i=1; i<=30; i++)); do curl -s "$0"; done' --"$inventoryFQDN"

run "kubectl --context ceposta-eks-1 exec deploy/parking -- bash -c 'for ((i=1; i<=15; i++)); do curl -s \"$inventoryFQDN\"; done' "

