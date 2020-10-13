#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD
#GLOOCTL=$(relative bin/glooctl)
#WASME=$(relative bin/wasme)
GLOOCTL=glooctl
WASME=wasme


CURRENT_BUILD=$(wasme list | grep ceposta/demo-add-header | awk '{ print $2}' | cut -d '.' -f 2 | sort -nr | head -n 1)
#DEMO_BUILD_NUMBER=$(($CURRENT_BUILD+1))
DEMO_BUILD_NUMBER=9

desc "Going to tag as webassemblyhub.io/ceposta/demo-add-header:v0.${DEMO_BUILD_NUMBER:-1}"
desc "Let's see what services we have deployed"
run "kubectl get po -n istio-system"
run "kubectl get po -n bookinfo"

desc "We can call between productpage and details services"
run "kubectl exec -it -n bookinfo deploy/productpage-v1 -c istio-proxy -- curl -v http://details.bookinfo:9080/details/123"

backtotop

desc "Let's create a new filter"
desc "We use the WebAssembly Hub CLI tool, wasme"

read -s
run "$WASME init ./filter"

pushd ./filter > /dev/null 2>&1

desc "Let's open our project"
run "code ."



#echo "Going to tag as webassemblyhub.io/ceposta/demo-add-header:v0.${DEMO_BUILD_NUMBER:-1}"

desc "Let's build our project"
run "$WASME build assemblyscript . -t webassemblyhub.io/ceposta/demo-add-header:v0.${DEMO_BUILD_NUMBER:-1}"
backtotop

desc "Let's list our locally built wasm modules"
run "$WASME list"
backtotop

desc "Now let's push it to the webassemblyhub registry"
run "$WASME push webassemblyhub.io/ceposta/demo-add-header:v0.${DEMO_BUILD_NUMBER:-1}"
backtotop
popd 

