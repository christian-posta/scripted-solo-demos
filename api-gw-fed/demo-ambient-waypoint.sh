#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD



backtotop
desc "-----====Demo Waypoint with Gloo Gateway ====-----"
read -s

desc "Let's say we want to give each team self service to configure their own microgateway"
desc "With Istio Ambient, L7 goes through a waypoint proxy which is a vanilla Envoy proxy"
desc "But let's say we want to use a full blown API Gateway (like Gloo Gateway)"
desc "Let's use the Gateway API to enable team self service and own their own microgateways based on Gloo Gateway"
read -s

desc "Let's start by deploying a waypoint based on gloo gateway"
run "cat resources/waypoints/web-api-waypoint.yaml"
run "kubectl apply -f resources/waypoints/web-api-waypoint.yaml"
run "kubectl get po -n web-api"

desc "Now let's let Istio know to use our API gateway"
run "kubectl label service web-api -n web-api istio.io/use-waypoint=web-api-gloo-waypoint"

desc "Let's specify some routing for our API Gateway"
run "cat resources/waypoints/web-api-httproute.yaml"
run "kubectl apply -f resources/waypoints/web-api-httproute.yaml"

desc "Let's call the web-api service"
run "kubectl exec -it deploy/sleep -- curl -v http://web-api.web-api:8080/"


