#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

desc "Did you run setup? (ENTER to continue)"
read -s

desc "TLS termination / lets encrypt"
run "cat default-tls-vs.yaml"
run "kubectl get certificates.cert-manager.io nip-io -o yaml"
run "kubectl get secret"
run "kubectl apply -n gloo-system -f default-tls-vs.yaml"

URL=$(glooctl proxy address | cut -f 1 -d ':').nip.io
desc "Call the API:"
run "curl -k https://$URL"

