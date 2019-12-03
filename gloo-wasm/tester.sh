#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD


desc "When ready, let's build:"
pushd project > /dev/null 2>&1
run "bazel build :envoy_filter_http_wasm_example.wasm --config=wasm --sandbox_writable_path $(bazel info output_base)/external/emscripten_toolchain/.emscripten_cache/"
popd
pwd


