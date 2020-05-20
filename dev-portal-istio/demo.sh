#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD
#GLOOCTL=$(relative bin/glooctl)
#WASME=$(relative bin/wasme)
GLOOCTL=glooctl
WASME=wasme


desc "Let's create a new filter"
desc "We use the WebAssembly Hub CLI tool, wasme"
run "$WASME init ./filter"

pushd ./filter > /dev/null 2>&1

desc "Let's open our project"
run "code ."

desc "Let's build our project"
run "$WASME build assemblyscript . -t webassemblyhub.io/ceposta/filter-demo:v0.1"

run "$WASME list"

desc "Now let's package our wasm module and push it to the remote registry"
run "$WASME push webassemblyhub.io/ceposta/filter-demo:v0.1"

run "$WASME list"

desc "Now let's configure the gateway to load the wasm module"

popd 


# split the screen and run the polling script in bottom script
tmux split-window -v -d -c $SOURCE_DIR
tmux select-pane -t 0
tmux send-keys -t 1 "curl -v http://localhost:8080/posts/1" 

read -s

# wasme deploy
run "wasme deploy envoy webassemblyhub.io/ceposta/filter-demo:v0.1 --config 'demo friends'"
