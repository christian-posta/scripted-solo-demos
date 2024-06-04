#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD


backtotop
desc "Let's say we want to add more sophisticated API Management to purchase-history"
read -s

desc "Let's start by deploying a waypoint for purchase-history"
run "kubectl apply -f resources/waypoints/purchase-history-waypoint.yaml"
run "kubectl get po -n purchase-history"

desc "Now let's let Istio know to use our API gateway"
run "kubectl label service purchase-history -n purchase-history istio.io/use-waypoint=purchase-history-gloo-waypoint"

desc "Let's specify some routing for our purchase-history API Gateway"
run "cat resources/waypoints/purchase-history-httproute-jwt.yaml"
run "kubectl apply -f resources/waypoints/purchase-history-httproute-jwt.yaml"

desc "Let's call the web-api service"
run "kubectl exec -it deploy/sleep -- curl -v http://web-api.web-api:8080/"

# get the JWT token into the env
source ./jwt.sh 

desc "We need to call the services with a JWT token"
run "kubectl exec -it deploy/sleep -- curl -H 'Authorization: Bearer $JWT' -v http://web-api.web-api:8080/"
