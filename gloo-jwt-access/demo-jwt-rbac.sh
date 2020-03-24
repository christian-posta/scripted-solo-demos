#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD


GLOO_PROXY_URL=$(kubectl get svc -n gloo-system | grep proxy | awk '{ print $4 }')

desc "Let's require RBAC"
run "cat resources/petstore-jwt-rbac-vs.yaml"

backtotop

desc "let's apply the jwt vs"
run "kubectl apply -f resources/petstore-jwt-rbac-vs.yaml"


backtotop

desc "Let's try call with a valid this token"
desc "Let's take a look at what one might look like: "
run "cat resources/jwt/token-iss-soloio.jwt"

VALID_TOKEN=$(cat resources/jwt/token-iss-soloio.jwt)

run "curl -v -H \"Authorization: Bearer $VALID_TOKEN\"  http://$GLOO_PROXY_URL/api/pets"

desc "This token doesn't have the right claims!"
desc "Let's try this one"
run "cat resources/jwt/token-iss-soloio-pets.jwt"
VALID_TOKEN=$(cat resources/jwt/token-iss-soloio-pets.jwt)


run "curl -v -H \"Authorization: Bearer $VALID_TOKEN\"  http://$GLOO_PROXY_URL/api/pets"

