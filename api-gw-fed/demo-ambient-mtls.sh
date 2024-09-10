#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD



backtotop
desc "-----====Demo Istio Ambient (sidecarless) ====-----"
read -s

desc "Let's start by installing the service mesh which should give us mTLS"
run "istioctl install -y --set profile=ambient"

run "istioctl version"
run "kubectl apply -f ~/dev/istio/istio-1.23.0/samples/addons/"

desc "Let's add each team/service to the mesh"
run "kubectl label namespace default web-api recommendation purchase-history istio.io/dataplane-mode=ambient"

desc "Let's put some traffic through"
run "for i in {1..100}; do kubectl exec -it deploy/sleep -- curl -s -o /dev/null --show-error http://web-api.web-api:8080/ ;  done"

desc "Let's go to Kiali"
desc "Remember to Port Forward it in another window"
desc "istioctl dashboard kiali"
read -s