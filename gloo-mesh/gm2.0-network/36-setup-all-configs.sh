#!/bin/bash

SOURCE_DIR=$PWD
source ./env.sh


# Install workspaces
kubectl --context $MGMT apply -f ./resources/workspaces/gateways-workspace.yaml
kubectl --context $MGMT apply -f ./resources/workspaces/bookinfo-workspace.yaml
kubectl --context $MGMT apply -f ./resources/workspaces/sleep-workspace.yaml


# Keeping these here for now until we add them to gitops

## bookinfo demo

# set up workspace settings
kubectl --context gm-cluster1 apply -f resources/workspaces/gateways/workspacesettings.yaml 
kubectl --context gm-cluster1 apply -f resources/workspaces/bookinfo/workspacesettings.yaml 
kubectl --context gm-cluster1 apply -f resources/workspaces/sleep/workspacesettings.yaml 

# expose things on the gloo-mesh-gateway
kubectl --context gm-cluster1 apply -f resources/workspaces/bookinfo/virtualdestination.yaml
kubectl --context gm-cluster1 apply -f resources/workspaces/bookinfo/routetable.yaml
kubectl --context gm-cluster1 apply -f resources/workspaces/gateways/virtualgateway.yaml


# set up failover
kubectl --context gm-cluster1 apply -f resources/workspaces/bookinfo/outlier-policy.yaml
kubectl --context gm-cluster1 apply -f resources/workspaces/bookinfo/failover-policy.yaml

# Set up fault injection
kubectl --context gm-cluster1 apply -f resources/workspaces/bookinfo/faultinjection-policy.yaml

# Set up all other routes
kubectl --context gm-cluster1 apply -f resources/workspaces/bookinfo/ratelimit-client-server.yaml
kubectl --context gm-cluster1 apply -f resources/workspaces/bookinfo/ratelimit-policy.yaml
kubectl --context gm-cluster1 apply -f resources/workspaces/bookinfo/ratelimit-serversettings.yaml
kubectl --context gm-cluster1 apply -f resources/workspaces/bookinfo/ratings-routetable.yaml

