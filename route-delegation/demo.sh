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

desc "Gloo discovered an upstream.  Let's take a look at what Gloo discovered"
run "glooctl get upstream default-petstore-8080"

desc "Let's look even closer at those functions it discovered"
run "glooctl get upstream default-petstore-8080 -o yaml"

