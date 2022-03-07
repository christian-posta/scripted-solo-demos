#!/bin/bash

source ./env-workshop.sh

kubectl --context $CLUSTER1 apply -f lab14-ratelimit-client-server.yaml
kubectl --context $CLUSTER1 apply -f lab14-ratelimit-policy.yaml
kubectl --context $CLUSTER1 apply -f lab14-ratelimit-routetable.yaml