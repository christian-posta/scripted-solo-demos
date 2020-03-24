#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD


desc "Let's see that we can hit the service"
GLOO_PROXY_URL=$(kubectl get svc -n gloo-system | grep proxy | awk '{ print $4 }')

run "curl -v http://$GLOO_PROXY_URL/api/pets"

backtotop

desc "Let's require a valid JWT to proceed"
run "cat resources/petstore-jwt-vs.yaml"

backtotop

desc "let's apply the jwt vs"
run "kubectl apply -f resources/petstore-jwt-vs.yaml"


backtotop

desc "Now try to hit the service"
run "curl -v http://$GLOO_PROXY_URL/api/pets"

desc "We need a valid JWT to access the service"
desc "Let's take a look at what one might look like: "
run "cat resources/jwt/token-iss-soloio.jwt"

desc "Let's inspect this token"
run "cat resources/certs/cert.pem"
read -s


backtotop

desc "Let's try call with this token"
VALID_TOKEN=$(cat resources/jwt/token-iss-soloio.jwt)

run "curl -v -H \"Authorization: Bearer $VALID_TOKEN\"  http://$GLOO_PROXY_URL/api/pets"

backtotop

desc "It worked!"
desc "Note, what if it was a valid token issued by someone other than the expected issuer?"
run "cat resources/jwt/token-iss-fooio.jwt"

desc "Check token"
read -s


desc "Let's try call with invalid token"
INVALID_TOKEN=$(cat resources/jwt/token-iss-fooio.jwt)

run "curl -v -H \"Authorization: Bearer $INVALID_TOKEN\"  http://$GLOO_PROXY_URL/api/pets"