#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD



backtotop
desc "-----====Demo Waypoint with Gloo Gateway ====-----"
read -s

desc "Let's start by installing the service mesh which should give us mTLS"
run "istioctl install -y --set profile=ambient"

# Let's also add the gloo-waypoint; we can gloss over this in the demo, adds more time
kubectl apply -f resources/waypoints/gloo-waypoint-gatewayclass.yaml > /dev/null 2>&1

run "istioctl version"
run "kubectl apply -f ~/dev/istio/istio-1.22.0/samples/addons/"

desc "Let's add each team/service to the mesh"
run "kubectl label namespace default istio.io/dataplane-mode=ambient"
run "kubectl label namespace web-api istio.io/dataplane-mode=ambient"
run "kubectl label namespace recommendation istio.io/dataplane-mode=ambient"
run "kubectl label namespace purchase-history istio.io/dataplane-mode=ambient"


desc "Let's put some traffic through"
run "for i in {1..5}; do kubectl exec -it deploy/sleep -- curl -v http://web-api.web-api:8080/ && printf \"\n\";  done"

desc "Let's go to Kiali"
desc "Remember to Port Forward it in another window"
desc "istioctl dashboard kiali"
read -s


backtotop
desc "That was just L4 traffic"
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


