#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh
. ../.env.sh

desc "Istio demo"
run "glooctl istio inject"

desc "Try call before we enable istio on the workloads"
echo "https://$DEFAULT_DOMAIN_NAME/"
read -s

backtotop
desc "enable Istio"
read -s

run "kubectl label namespace default istio-injection=enabled"
run "kubectl rollout restart deployment/web-api"
run "kubectl rollout restart deployment/recommendation"
run "kubectl rollout restart deployment/purchase-history-v1"

desc "Enable strict mtls"
run "kubectl apply -f default-peerauth-strict.yaml"

desc "try call web-api"
echo "https://$DEFAULT_DOMAIN_NAME/"
read -s

backtotop
desc "enable mtls on the upstream"
read -s

run "glooctl istio enable-mtls --upstream default-web-api-8080"

desc "try call web-api"
echo "https://$DEFAULT_DOMAIN_NAME/"
