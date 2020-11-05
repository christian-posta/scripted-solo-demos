#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh
. ../.env.sh

desc "TLS termination / lets encrypt"
run "cat ./default-vs-tls.yaml"
run "kubectl apply -n gloo-system -f ./default-vs-tls.yaml"

echo "Call this in the browser! https://$DEFAULT_DOMAIN_NAME/"

