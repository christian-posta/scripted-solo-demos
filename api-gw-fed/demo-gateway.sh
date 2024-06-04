#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD



backtotop
desc "-----====Demo Gateway API -- Gloo Gateway ====-----"
read -s


desc "Deploying a Gateway with Kubernetes API Gateway"
run "cat resources/gloo-http-gateway.yaml"
run "kubectl apply -f resources/gloo-http-gateway.yaml"

desc "Check the Gateway was deployed"
run "kubectl get po -n gloo-system"

desc "Deploying a Route with Kubernetes API Gateway"
run "cat resources/httproute-web-api.yaml"
run "kubectl apply -f resources/httproute-web-api.yaml"

desc "Check the route was accepted"
run "kubectl get httproute -n gloo-system"

desc "Let's see if we can call this route"

export GATEWAY_IP=$(kubectl get gateway -n gloo-system | grep http | awk  '{ print $3 }')
run "curl -v -H 'Host: web-api.solo.io' http://$GATEWAY_IP:8080/"




