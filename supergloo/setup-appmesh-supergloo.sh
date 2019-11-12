#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD



# Create the namespace to which bookinfo will be deployed
kubectl create ns bookinfo-appmesh
supergloo create secret aws --name aws --namespace supergloo-system --profile default --file ~/.aws/credentials 



## Can use this command if the interactive mode doesn't work
#supergloo register appmesh --name demo-appmesh --namespace supergloo-system --secret supergloo-system.aws --region us-west-2 --auto-inject true --select-namespaces bookinfo-appmesh --virtual-node-label vn-name
