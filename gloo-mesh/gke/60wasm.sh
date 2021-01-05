#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

SOURCE_DIR=$PWD
source env.sh
kubectl config use-context $MGMT_CONTEXT

# get the sleep container up
kubectl --context $CLUSTER_1 apply -f ./resources/sleep.yaml
kubectl --context $MGMT_CONTEXT apply -f ./resources/enable-sleep-acp.yaml

desc "When we call the reviews-v2 service, we see the following"
run "kubectl --context $CLUSTER_1 exec -it deploy/sleep -c sleep -- curl -v reviews:9080/reviews/1"

desc "Let's deploy a wasm module"
run "cat ./resources/wasm-deployment.yaml"
run "kubectl apply -f ./resources/wasm-deployment.yaml"

desc "Check deployment of wasm"
run "kubectl get wasmdeployment -n gloo-mesh reviews-wasm -o yaml"

desc "Now try call reviews-v2"
run "kubectl --context $CLUSTER_1 exec -it deploy/sleep -c sleep -- curl -v reviews:9080/reviews/1"
