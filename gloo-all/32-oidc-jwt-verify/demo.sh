#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

desc "Be sure to use localhost:8080 since running dex local"
read -s

desc "Let's verify the jwt and grab the claims"
desc "we want to pass the verified headers to the client, not the jwt"
read -s
run "cat dex-oidc-xform-httpbin-vs.yaml"
run "kubectl apply -f dex-oidc-xform-httpbin-vs.yaml"

desc "now go check out the httpbin output"
