#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD

desc "We should have Gloo deployed, let's create a route to a service and verify it works"
run "glooctl add route --name default --path-prefix / --dest-name default-echo-server-8080"
run "glooctl get vs"
run "curl -v $(glooctl proxy url)"

desc "Now, let's deploy a wasm module"
desc "Let's open our project"
run "clion project"

desc "Go implement the method to manipulate the headers"
read -s

desc "When ready, let's build:"
pushd project > /dev/null 2>&1
run "bazel build :envoy_filter_http_wasm_example.wasm --config=wasm --sandbox_writable_path $(bazel info output_base)/external/emscripten_toolchain/.emscripten_cache/"
popd

desc "Now let's push to the registry"
run "./bin/extend-envoy push gcr.io/solo-public/christian-wasm:0.1-kubecon project/bazel-bin/envoy_filter_http_wasm_example.wasm"

desc "Now let's configure the gateway to load the wasm module"
run "cat resources/gateway-v2-wasm.yaml"
run "kubectl apply -f resources/gateway-v2-wasm.yaml"

#TODO: should we view the envoy config?

desc "Let's call the proxy again"
run "curl -v $(glooctl proxy url)"
