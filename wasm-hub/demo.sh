#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD
#GLOOCTL=$(relative bin/glooctl)
#WASME=$(relative bin/wasme)
GLOOCTL=glooctl
WASME=wasme


desc "Let's see what services we have deployed"
run "kubectl get po"

desc "We should have Gloo deployed, let's create a route to a service and verify it works"
run "$GLOOCTL add route --name default --path-prefix / --dest-name default-echo-server-8080"
run "$GLOOCTL get vs"
run "curl -I $($GLOOCTL proxy url)"

desc "Let's create a new filter"
desc "We use the WebAssembly Hub CLI tool, wasme"
run "$WASME init ./filter"

pushd ./filter > /dev/null 2>&1

desc "Let's open our project"
run "code ."

desc "Let's build our project"
run "$WASME build . -t webassemblyhub.io/christian-posta/filter-demo:v0.1"

run "$WASME list"

desc "Now let's package our wasm module and push it to the remote registry"
run "$WASME push webassemblyhub.io/christian-posta/filter-demo:v0.1"

run "$WASME list --published"


desc "Now let's configure the gateway to load the wasm module"

popd 

# wasme deploy
run "wasme deploy gloo webassemblyhub.io/christian-posta/filter-demo:v0.1 --id=add-header --config '{\"name\":\"hello\",\"value\":\"World!\"}'"

#run "cat resources/gateway-wasm.yaml"
#run "kubectl apply -f resources/gateway-wasm.yaml"


desc "Let's call the proxy again"
run "curl -I $($GLOOCTL proxy url)"

pushd ./filter > /dev/null 2>&1

desc "Excellent! now let's publish our wasm module to the WebAssembly Hub catalog"
run "$WASME catalog add webassemblyhub.io/christian-posta/filter-demo:v0.1"

desc "Verify the PR opened to the WebAssembly Hub Catalog"
read -s