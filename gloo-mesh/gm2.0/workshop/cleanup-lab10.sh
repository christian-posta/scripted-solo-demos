#!/bin/bash

source ./env-workshop.sh

kubectl --context $CLUSTER1 delete -f lab10-virtualdestination.yaml
kubectl --context $CLUSTER1 apply -f lab7-bookinfo-routetable.yaml
kubectl --context $CLUSTER1 delete -f lab10-failoverpolicy.yaml
kubectl --context $CLUSTER1 delete -f lab10-virtualdest-failover.yaml