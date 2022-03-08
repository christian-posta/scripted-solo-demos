#!/bin/bash

source ./env-workshop.sh

kubectl --context $CLUSTER1 delete ns gogs
kubectl --context $CLUSTER1 delete ns argocd