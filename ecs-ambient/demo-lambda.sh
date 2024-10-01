#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD

desc "Quick Istio Demo for Istio Ambient + Lambda"
read -s

desc "Let's invoke the lambda and pass config for it to call our echo.default service"
run "aws lambda invoke --function-name ceposta-echo-ztunnel-vpc /dev/stdout --payload '{\"url\":\"http://echo.default\"}' --cli-binary-format raw-in-base64-out | jq "

desc "Now let's call httpbin service"
run "aws lambda invoke --function-name ceposta-echo-ztunnel-vpc /dev/stdout --payload '{\"url\":\"http://httpbin.default:8080/headers\"}' --cli-binary-format raw-in-base64-out | jq "


desc "Go check the lambda logs for the connection information"
read -s
backtotop


desc "Let's add a waypoint for the default namespace to add L7 policies"
run "istioctl waypoint apply --enroll-namespace --for service --namespace default --context ceposta-eks-3"

desc "Let's add header manipulations to calls to httpbin"
run "cat resources/add-headers.yaml"
run "kubectl --context ceposta-eks-3 apply -f resources/add-headers.yaml"


desc "Now let's call httpbin service"
run "aws lambda invoke --function-name ceposta-echo-ztunnel-vpc /dev/stdout --payload '{\"url\":\"http://httpbin.default:8080/headers\"}' --cli-binary-format raw-in-base64-out | jq "

## let's clean up
