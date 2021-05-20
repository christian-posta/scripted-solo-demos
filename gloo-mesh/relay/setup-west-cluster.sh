#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

SOURCE_DIR=$PWD
source env.sh
source relay-ports.sh

echo "Installing Istio"
istioctl1.8 --context $CLUSTER_1 install -y -f resources/istio-control-plane-fips.yaml

echo "Using Relay: $RELAY_ADDRESS"

meshctl cluster register enterprise --remote-context=$CLUSTER_1  --relay-server-address $RELAY_ADDRESS $CLUSTER_1_NAME
