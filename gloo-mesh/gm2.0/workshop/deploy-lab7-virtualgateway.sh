#!/bin/bash

source ./env-workshop.sh


# prep certs

kubectl --context ${CLUSTER1} -n istio-gateways create secret generic tls-secret \
--from-file=tls.key=./certs/tls.key \
--from-file=tls.crt=./certs/tls.crt

kubectl --context ${CLUSTER2} -n istio-gateways create secret generic tls-secret \
--from-file=tls.key=./certs/tls.key \
--from-file=tls.crt=./certs/tls.crt

kubectl --context $CLUSTER1 apply -f lab7-virtualgateway.yaml
kubectl --context $CLUSTER1 apply -f lab7-bookinfo-routetable.yaml


export ENDPOINT_HTTPS_GW_CLUSTER1=$(kubectl --context ${CLUSTER1} -n istio-gateways get svc istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].*}'):443


echo "go to:"

echo "https://${ENDPOINT_HTTPS_GW_CLUSTER1}/productpage"