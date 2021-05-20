#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

SOURCE_DIR=$PWD
source env.sh
source relay-ports.sh

echo "Installing Istio"
istioctl1.9 --context $CLUSTER_2 install -y -f resources/istio-control-plane.yaml

echo "Using Relay: $RELAY_ADDRESS"

meshctl cluster register enterprise --remote-context=$CLUSTER_2  --relay-server-address $RELAY_ADDRESS $CLUSTER_2_NAME
