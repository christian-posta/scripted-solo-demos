#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh
. ../.env.sh

desc "let's xform that to be a jwt token"
run "cat dex-oidc-xform-httpbin-vs.yaml"
run "kubectl apply -f dex-oidc-xform-httpbin-vs.yaml"

desc "But what does the client end up seeing?"
desc "go check page now: https://$DEFAULT_DOMAIN_NAME/httpbin"
read -s
