#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh
. ../.env.sh

kubectl delete cm -n dev-portal dev-portal-petstore-image
# avoid the race
kubectl create -f ./complete/configmaps
kubectl apply -f ./complete
