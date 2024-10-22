#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD


#### Make sure that you run some commands before this part to set up the demo
#### Show the cluster
# kubectl get po -n default -o wide
# kubectl get ns default --show-labels



desc "Quick Istio Demo for Amazon ECS"
read -s

desc "Let's enforce network policy with SPIFFE universal workload identity"
run "cat resources/deny-shell-ecs-to-httpbin.yaml"
run "kubectl --context ceposta-eks-3 apply -f resources/deny-shell-ecs-to-httpbin.yaml"

desc "Go try and call httpbin from ECS: it should not work"
read -s


desc "Let's add a waypoint for the default namespace to add L7 policies"
run "istioctl waypoint apply --enroll-namespace --for service --namespace default --context ceposta-eks-3"

desc "Let's add fault injection to calls to httpbin"
run "cat resources/faultinjection.yaml"
run "kubectl --context ceposta-eks-3 apply -f resources/faultinjection.yaml"

desc "Let's call httpbin from sleep"
run "kubectl exec -it deploy/sleep -- time curl httpbin.default:8080/headers"
