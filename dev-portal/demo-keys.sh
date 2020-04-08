#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD

desc "Petstore API"
run "curl -H 'host: localhost:8080' $(glooctl proxy url)/api/pets -v"


desc "Port forward the dev portal"
run "kubectl port-forward -n gloo-system deploy/dev-portal 1234:8080"
