#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

desc "TLS termination"
run "cat default-tls-vs.yaml"
run "kubectl create secret tls upstream-tls --key web-api.key --cert web-api.crt --namespace gloo-system"
run "kubectl apply -n gloo-system -f default-tls-vs.yaml"

URL=$(glooctl proxy url)
desc "Call the API:"
run "curl $URL"

URL=$(glooctl proxy url --port https)
run "curl $URL"
run "curl -k $URL"

