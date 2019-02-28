#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

glooctl delete virtualservice default
glooctl delete upstream default-petstore-8080
kubectl delete -f $(relative petstore.yaml)