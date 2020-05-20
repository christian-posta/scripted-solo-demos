#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

SOURCE_DIR=$PWD
source env.sh

desc "create the gloo namespace"
run "kubectl create -f ../resources/gloo/control-plane/namespace.yaml --context $CLUSTER_1"

desc "federate the namespace"
run "kubefedctl federate -f ../resources/gloo/control-plane/namespace.yaml | kubectl --context $CLUSTER_1 apply -f -"

desc "enable federation of CRDs"
run "kubefedctl enable customresourcedefinitions"

desc "federate the gloo crds"
run "kubefedctl federate crd -f ../resources/gloo/crds/gloo-crds.yaml | kubectl --context $CLUSTER_1 apply -f -"
run "kubectl get federatedcustomresourcedefinition -n gloo-system --context $CLUSTER_1"
run "kubectl get federatedcustomresourcedefinition virtualservices.gateway.solo.io -o yaml -n gloo-system --context $CLUSTER_1"