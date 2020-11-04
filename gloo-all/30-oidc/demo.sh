#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh
. ../.env.sh

desc "Before we continue, go see the app on localhost"
desc "https://$DEFAULT_DOMAIN_NAME/"
desc "https://$DEFAULT_DOMAIN_NAME/ui"
desc "https://$DEFAULT_DOMAIN_NAME/httpbin"
read -s
backtotop

desc "Set up dex oidc in gloo ext auth"
run "cat dex-oidc-authconfig.yaml"
run "kubectl apply -f dex-oidc-authconfig.yaml"


desc "Update virtual service with OIDC config"
run "cat dex-oidc-vs.yaml"
run "kubectl apply -f dex-oidc-vs.yaml"

desc "go check page now: https://$DEFAULT_DOMAIN_NAME/httpbin"
desc "Login in admin@example.com :: password"
