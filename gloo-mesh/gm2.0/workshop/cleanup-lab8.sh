#!/bin/bash

source ./env-workshop.sh

kubectl --context $CLUSTER1 delete -f lab8-faultinjection-routetable.yaml
kubectl --context $CLUSTER1 delete -f lab8-faultinjection-policy.yaml
kubectl --context $CLUSTER1 delete -f lab8-retry-timeout-routetable.yaml
kubectl --context $CLUSTER1 delete -f lab8-retry-timeout-policy.yaml

kubectl --context $CLUSTER1 apply -f lab7-bookinfo-routetable.yaml
