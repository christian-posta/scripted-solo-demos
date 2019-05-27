#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

SOURCE_DIR=$PWD

kubectl create ns test
kubectl apply -f $(relative podinfo-deployment.yaml)
kubectl apply -f $(relative podinfo-hpa.yaml)