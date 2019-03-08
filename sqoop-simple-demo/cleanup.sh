#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh
kubectl delete -f $(relative petstore.yaml) 
kubectl delete schema petstore -n gloo-system
kubectl delete resolvermap petstore -n gloo-system