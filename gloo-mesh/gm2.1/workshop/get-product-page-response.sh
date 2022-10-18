#!/bin/bash

source ./env-workshop.sh

export ENDPOINT_HTTPS_GW_CLUSTER1=$(kubectl --context ${CLUSTER1} -n istio-gateways get svc istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].*}'):443


echo "https://${ENDPOINT_HTTPS_GW_CLUSTER1}/productpage"


curl -I -sk https://${ENDPOINT_HTTPS_GW_CLUSTER1}/productpage

# to invoke rate limiting...
#
# curl -I -H "x-type: a" -H "x-number: one" -sk https://${ENDPOINT_HTTPS_GW_CLUSTER1}/productpage