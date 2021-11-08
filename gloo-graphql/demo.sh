#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD

desc "Expose Petstore REST API on gloo edge gateway"
run "kubectl apply -f ./petstore-rest.yaml"

desc "Try call through the gateway"
run "kubectl exec -it deploy/sleep -- curl gateway-proxy.gloo-system/all-pets"

backtotop
desc "Now let's change the virtual service routing to be a GraphQL endpoint"
read -s

desc "First create the GraphQL Schema. Go check it out first"
read -s
run "kubectl apply -f ./gql.yaml"

desc "Now let's apply this to the virtual service. Go check it out first"
read -s
run "kubectl apply -f ./petstore-graphql.yaml"

desc "Now try call with a graphql query selecting only names of pets"
run "kubectl exec -it deploy/sleep -- curl gateway-proxy.gloo-system/graphql -H 'Content-Type: application/json' -d '{\"query\":\"{pets{name}}\"}'"


