#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD

desc "Create all assets"
run "kubectl create -f resources/assets.yaml"

desc "Create an API doc"
run "kubectl apply -f resources/petstore-apidocs.yaml"

desc "Create API product"
run "kubectl apply -f resources/petstore-apiproduct.yaml"

desc "Try curl Istio gateway"
run "curl -H 'host: petstore.org' localhost:8080/api/pets"

desc "Create API product with a usage plan"
run "cat resources/petstore-apiproduct-plan.yaml | yq .spec.plans"
run "kubectl apply -f resources/petstore-apiproduct-plan.yaml"
run "curl -v -H 'host: petstore.org' localhost:8080/api/pets"

desc "Create a user"
run "kubectl apply -f resources/user-ceposta.yaml"

desc "Create a portal"
run "kubectl apply -f resources/petstore-portal.yaml"

desc "Go check the API keys"
read -s

run "curl -v -H 'api-key: YTQyMjcwYTUtNzg4NS1iMjZmLWQ1YmMtMjdkOWU4ZDVlNmEw'  -H 'host: petstore.org' localhost:8080/api/pets"