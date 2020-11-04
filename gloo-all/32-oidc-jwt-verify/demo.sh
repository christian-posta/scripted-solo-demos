#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh
. ../.env.sh

desc "Let's verify the jwt and grab the claims"
desc "we want to pass the verified headers to the client, not the jwt"
read -s
run "cat dex-oidc-xform-httpbin-vs.yaml"
run "kubectl apply -f dex-oidc-xform-httpbin-vs.yaml"

desc "go check page now: https://$DEFAULT_DOMAIN_NAME/httpbin"
