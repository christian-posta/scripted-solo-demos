#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD

desc "Let's see what services we have deployed"
run "kubectl get po"

desc "We should have Gloo deployed, let's create a route to a service and verify it works"
run "glooctl add route --name default --path-prefix / --dest-name default-echo-server-8080"
run "glooctl get vs"
run "curl -v $(glooctl proxy url)"

desc "Let's create a new filter"
desc "We use the WebAssembly Hub CLI tool, wasme"
run "wasme init ./filter"

pushd ./filter > /dev/null 2>&1

desc "Let's open our project"
run "clion ."

desc "Let's build our project"
run "wasme build ."

desc "Now let's package our wasm module and push it to the registry"
run "wasme push webassemblyhub.io/christian-posta/filter-test:v0.2 _output/filter.wasm"


desc "Do we see our new module?"
run "wasme list"

desc "Now let's configure the gateway to load the wasm module"

popd 

run "cat resources/gateway-v2-wasm.yaml"
run "kubectl apply -f resources/gateway-v2-wasm.yaml"



desc "Let's call the proxy again"
run "curl -v $(glooctl proxy url)"

pushd ./filter > /dev/null 2>&1

desc "Excellent! now let's publish our wasm module"
run "wasme catalog add webassemblyhub.io/christian-posta/filter-test:v0.2"

desc "Verify the PR opened to the WebAssembly Hub Catalog"
read -s