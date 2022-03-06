#!/bin/bash

source ./env-workshop.sh

kubectl --context $CLUSTER1 delete -f lab8-faultinjection.yaml
kubectl --context $CLUSTER1 delete -f lab8-retry-timeout.yaml
