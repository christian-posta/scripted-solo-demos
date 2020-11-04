#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh
. ../.env.sh

desc "Let's use an opa module:"
run "cat check-jwt.rego"
run "kubectl -n gloo-system create configmap allow-jwt --from-file=check-jwt.rego"

run "cat dex-oidc-authconfig.yaml"
run "kubectl apply -f dex-oidc-authconfig.yaml"

run "cat dex-oidc-xform-httpbin-vs.yaml"
run "kubectl apply -f dex-oidc-xform-httpbin-vs.yaml"

desc "go check page now: https://$DEFAULT_DOMAIN_NAME/httpbin"
