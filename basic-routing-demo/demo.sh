#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD

desc "A simple Kubernetes Service: Petstore API"
run "cat $(relative petstore.yaml)"

backtotop

desc "Create the Petstora API"
run "kubectl apply -f $(relative petstore.yaml)"

run "kubectl get pod -w -n default"

desc "Let's call this service and examine its swagger"
run "kubectl run -i --rm --restart=Never dummy --image=dockerqa/curl:ubuntu-trusty --command curl petstore:8080/swagger.json"

backtotop

desc "Gloo should have discovered this UPSTREAM"
run "glooctl get upstream"

desc "Gloo can discovery swagger. Let's take a look at what Gloo discovered"
run "glooctl get upstream default-petstore-8080"

desc "Let's look even closer at those functions it discovered"
run "glooctl get upstream default-petstore-8080 -o yaml"

backtotop

desc "Let's do something simple. Let's create a route to the petstore using basic reverse proxying"
run "glooctl add route --path-exact /sample-route-1 --dest-name default-petstore-8080 --prefix-rewrite /api/pets"

desc "Gloo uses VirtualService object to expose an virtual API of routing rules."
desc "Let's see this new VirtualService"
run "glooctl get virtualservice"
run "glooctl get virtualservice default -o yaml"

backtotop

desc "Let's try calling our newly exposed service"
run "glooctl proxy url"
run "curl $(glooctl proxy url)/sample-route-1"

desc "We can also add routes interactively"
read -s
