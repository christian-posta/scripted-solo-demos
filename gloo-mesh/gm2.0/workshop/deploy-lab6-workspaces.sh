#!/bin/bash


source ./env-workshop.sh



kubectl --context $MGMT apply -f lab6-workspaces.yaml
kubectl --context $CLUSTER1 apply -f lab6-workspacesettings.yaml