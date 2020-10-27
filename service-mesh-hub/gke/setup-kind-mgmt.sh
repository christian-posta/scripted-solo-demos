#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

SOURCE_DIR=$PWD
source env.sh

kind create cluster --name smh-management

kubectl config use-context $MGMT_CONTEXT

meshctl install

echo "installing the UI (separate for now, but will be bundled)"
./setup-ui.sh

echo "Finished installing UI (ENTER to continue)"
read -s

