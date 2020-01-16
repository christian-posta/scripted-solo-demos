#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD

desc "Get pods"
run "kubectl get po"
run "kubectl get po -n gloo-system"


desc "Set up routing, simulating multiple APIs"
desc "Take a look at the banking-vs-allinone.yaml"
read -s
#run "cat $(relative banking-vs-allinone.yaml)"

backtotop

desc "Let's apply this and see if it works:"
run "kubectl apply -f $(relative banking-vs-allinone.yaml)"
run "glooctl proxy url"

desc "Go open URL in browser"
read -s
backtotop

desc "Let's separate routing into separate route tables"
desc "Let's take a look at the riskscreen-routes.yaml"
read -s
#run "cat $(relative route-table/riskscreen-routes.yaml)"
run "kubectl apply -f $(relative route-table/)"

desc "Let's take a look at the VirtualService now to show delegation"
read -s
#run "cat $(relative banking-vs-delegate.yaml)"
run "kubectl apply -f $(relative banking-vs-delegate.yaml)"

desc "Check still works in the browser"
read -s
backtotop

desc "As an operator I want to implement various security features, like OIDC"
desc "Let's do that with Gloo VirtualService"
desc "Let's see the banking-vs-oidc.yaml"
read -s
#run "cat $(relative banking-vs-oidc.yaml)"
run "kubectl apply -f $(relative banking-vs-oidc.yaml)"

desc "Go check OIDC now enforced"
read -s
backtotop

desc "As developers, we want to control routing, transformation, retries, etc"
desc "Let's see that with Gloo RouteTable"
desc "Take a look a the routtable again with transformation in it:"
read -s
#run "cat $(relative route-table-transformation/riskscreen-routes.yaml)"
run "kubectl apply -f $(relative route-table-transformation/)"
