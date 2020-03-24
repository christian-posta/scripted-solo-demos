#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD


desc "Verify you can get to the service"
glooctl proxy url
read -s

backtotop

desc "Set up dex oidc in gloo ext auth"
run "cat resources/dex-oidc-authconfig.yaml"

backtotop

desc "apply resources"
run "kubectl apply -f resources/dex-oidc-authconfig.yaml"


desc "Update virtual service with OIDC config"
run "cat resources/dex-oidc-vs.yaml"

backtotop

desc "apply resources"
run "kubectl apply -f resources/dex-oidc-vs.yaml"

desc "go check page now"
desc "Login in admin@example.com :: password"
read -s


desc "What about fine grained authz with OPA?"
run "cat resources/check-jwt.rego"

desc "Create the Auth Policy"
run "kubectl apply -f resources/dex-oidc-opa-authconfig.yaml"
run "kubectl apply -f resources/dex-oidc-jwt-vs.yaml"

desc "Now we have OIDC + AuthZ with OPA JWT checks"
desc "Go to the browser and check against user: user@example.com and go to /owners"
read -s