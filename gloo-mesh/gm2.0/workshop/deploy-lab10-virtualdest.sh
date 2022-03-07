#!/bin/bash

source ./env-workshop.sh

# comment out for now since we aren't going to use https
kubectl --context $CLUSTER1 apply -f lab10-virtualdestination.yaml
kubectl --context $CLUSTER1 apply -f lab10-routetable.yaml

# Run the following for the demo
# kubectl --context $CLUSTER1 apply -f lab10-failoverpolicy.yaml
# kubectl --context $CLUSTER1 apply -f lab10-virtualdest-failover.yaml
#