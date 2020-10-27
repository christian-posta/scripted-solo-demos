#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

desc "Be sure to use localhost:8080 since running dex local"
read -s

desc "let's xform that to be a jwt token"
run "cat dex-oidc-xform-httpbin-vs.yaml"
run "kubectl apply -f httpbin-static-upstream.yaml"
run "kubectl apply -f dex-oidc-xform-httpbin-vs.yaml"

desc "But what does the client end up seeing?"
desc "go check page now: http://localhost:8080/httpbin"
read -s
