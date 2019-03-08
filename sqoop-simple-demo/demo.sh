#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD

desc "A simple Kubernetes Service: Petstore API"
run "cat $(relative petstore.yaml)"

backtotop

desc "Create the Petstora API"
run "kubectl apply -f $(relative petstore.yaml)"

run "kubectl get pod -w"


backtotop

desc "Gloo can discovery swagger. Let's take a look at what Gloo discovered"
run "glooctl get upstream default-petstore-8080 -o yaml"

backtotop


desc "Let's create a quick GraphQL schema:"
run "cat $(relative petstore.schema.graphql)"

desc "Let's send this to Sqoop"
run "sqoopctl schema create petstore -f $(relative petstore.schema.graphql)"
run "kubectl get schema -n gloo-system"


desc "Let's take a look at the Resolvers that were automatically created"
run "kubectl get resolvermap  petstore -o yaml -n gloo-system"

desc "Register some resolvers"
run "sqoopctl resolvermap register -u default-petstore-8080 -s petstore -g findPets Query pets"
run "sqoopctl resolvermap register -u default-petstore-8080 -s petstore -g findPetById Query pet"
run "sqoopctl resolvermap register -u default-petstore-8080 -s petstore -g addPet Mutation addPet --request-template '{{ marshal (index .Args \"pet\") }}'"

run "kubectl get resolvermap  petstore -o yaml -n gloo-system"


SQOOP_URL=$(echo http://$(minikube ip):$(kubectl get svc sqoop -n gloo-system -o 'jsonpath={.spec.ports[?(@.name=="http")].nodePort}'))

open $SQOOP_URL