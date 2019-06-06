#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

kubectl apply -f $(relative petstore.yaml)
glooctl add route --path-exact /sample-route-1 --dest-name default-petstore-8080 --prefix-rewrite /api/pets

glooctl proxy url