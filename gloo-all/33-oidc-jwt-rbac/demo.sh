#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

desc "Be sure to use localhost:8080 since running dex local"
read -s

desc "Let's use rbac on the claims"
run "cat dex-oidc-xform-httpbin-vs.yaml"
run "kubectl apply -f dex-oidc-xform-httpbin-vs.yaml"

desc "now go check out the httpbin output"
