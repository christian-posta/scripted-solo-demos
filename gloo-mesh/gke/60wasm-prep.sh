#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

SOURCE_DIR=$PWD
source env.sh
kubectl config use-context $MGMT_CONTEXT

kubectl apply --context $CLUSTER_1 -n default -f ./resources/bootstrap-ecds-cm.yaml
kubectl apply --context $CLUSTER_2 -n default -f ./resources/bootstrap-ecds-cm.yaml


kubectl patch deployment -n default reviews-v2 --context ${CLUSTER_1} --patch='{"spec":{"template": {"metadata": {"annotations": {"sidecar.istio.io/bootstrapOverride": "gloo-mesh-custom-envoy-bootstrap"}}}}}'  --type=merge