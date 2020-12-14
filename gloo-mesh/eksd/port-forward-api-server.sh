#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

SOURCE_DIR=$PWD
source env.sh

EXISTING_PID=$(ps aux | grep port-forward | grep gloo-mesh-console | awk '{print $2}')
kill -9 $EXISTING_PID > /dev/null 2>&1
kubectl --context $MGMT_CONTEXT port-forward -n gloo-mesh svc/gloo-mesh-console 8090  > /dev/null 2>&1 &
