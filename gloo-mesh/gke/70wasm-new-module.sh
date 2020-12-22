#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

SOURCE_DIR=$PWD
source env.sh
kubectl config use-context $MGMT_CONTEXT

WASME='meshctl wasm'
LANGUAGE=${1:-assemblyscript}
CURRENT_BUILD=$(meshctl wasm list | grep ceposta/mesh-add-header | awk '{ print $2}' | cut -d '.' -f 2 | sort -nr | head -n 1)
DEMO_BUILD_NUMBER=$(($CURRENT_BUILD+1))
#DEMO_BUILD_NUMBER=11

desc "Going to tag as webassemblyhub.io/ceposta/mesh-add-header:v0.${DEMO_BUILD_NUMBER:-1}"

desc "Let's create a new filter"

read -s
run "$WASME init ./filter"

pushd ./filter > /dev/null 2>&1

desc "Let's open our project"
run "code ."


desc "Let's build our project"
run "$WASME build $LANGUAGE . -t webassemblyhub.io/ceposta/mesh-add-header:v0.${DEMO_BUILD_NUMBER:-1}"
# wasme build assemblyscript . -t webassemblyhub.io/ceposta/mesh-add-header:v0.15
# wasme build tinygo . -t webassemblyhub.io/ceposta/mesh-add-header:v0.15
backtotop

desc "Let's list our locally built wasm modules"
run "$WASME list"
backtotop

desc "Now let's push it to the webassemblyhub registry"
run "$WASME push webassemblyhub.io/ceposta/mesh-add-header:v0.${DEMO_BUILD_NUMBER:-1}"
backtotop
popd 

