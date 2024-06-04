#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD



backtotop
desc "-----====Demo Gateway API -- Gloo Gateway ====-----"
read -s

desc "We have three apps: web-api, recommendation, purchase-history"
run "kubectl get namespaces"
run "kubectl get po -n web-api"
run "kubectl exec -it deploy/sleep -- curl -v http://web-api.web-api:8080/"


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
run "kubectl get svc -n gloo-system"

export GATEWAY_IP=$(kubectl get gateway -n gloo-system | grep http | awk  '{ print $3 }')
run "curl -v -H 'Host: web-api.solo.io' http://$GATEWAY_IP:8080/"

desc "Let's implement rate limiting for this API"
run "cat ./resources/extensions/httproute-web-api-ratelimit.yaml"
run "kubectl apply -f ./resources/extensions/httproute-web-api-ratelimit.yaml"

desc "Let's call the API 3 times so we can trip rate limit"
run "for i in {1..3}; do curl -v -H 'Host: web-api.solo.io' -I http://$GATEWAY_IP:8080/ && printf \"\n\";  done"

desc "Now this call should trip Rate Limit"
run "curl -v -H 'Host: web-api.solo.io' -I http://$GATEWAY_IP:8080/"



