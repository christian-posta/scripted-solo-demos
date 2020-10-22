#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

SOURCE_DIR=$PWD
source env.sh

kind create cluster --name smh-management

kubectl config use-context $MGMT_CONTEXT

meshctl install

echo "installing the UI (separate for now, but will be bundled)"
./setup-ui.sh
read -s


echo "SMH UI now available on port 8090"
echo "kubectl port-forward -n service-mesh-hub svc/service-mesh-hub-console 8090  > /dev/null 2>&1 &"
kubectl port-forward -n service-mesh-hub svc/service-mesh-hub-console 8090  > /dev/null 2>&1 &
