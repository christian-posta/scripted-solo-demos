#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

SOURCE_DIR=$PWD
source env.sh
EXISTING_PID=$(ps aux | grep port-forward | grep istio-ingressgateway | awk '{print $2}')
kill -9 $EXISTING_PID
kubectl --context $CLUSTER_1 -n istio-system port-forward svc/istio-ingressgateway  9080:80
