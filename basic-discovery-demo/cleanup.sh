#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

kubectl delete -f $(relative petstore.yaml)