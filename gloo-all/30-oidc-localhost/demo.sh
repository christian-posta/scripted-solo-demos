#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

desc "Be sure to use localhost:8080 since running dex local"
read -s

desc "Set up dex oidc in gloo ext auth"
run "cat dex-oidc-authconfig.yaml"
run "kubectl apply -f dex-oidc-authconfig.yaml"


desc "Update virtual service with OIDC config"
run "cat dex-oidc-vs.yaml"
run "kubectl apply -f dex-oidc-vs.yaml"

desc "go check page now: http://localhost:8080"
desc "Login in admin@example.com :: password"
