#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

SOURCE_DIR=$PWD
source env.sh

kubectl --contex $MGMT_CONTEXT port-forward -n gloo-mesh svc/gloo-mesh-console 8090  > /dev/null 2>&1 &
