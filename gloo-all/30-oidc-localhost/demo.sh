#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

# Idempotent Set up
kubectl apply -f ../resources/gloo/default-vs.yaml &> /dev/null

glooctl create secret oauth --client-secret secretvalue oauth &> /dev/null

kill -9 $(ps aux | grep port-forward | grep svc/dex | awk '{print $2}') &> /dev/null

kubectl -n gloo-system port-forward svc/dex 32000:32000  &> /dev/null &  

kill -9 $(ps aux | grep port-forward | grep svc/gateway-proxy | awk '{print $2}') &> /dev/null

kubectl -n gloo-system port-forward svc/gateway-proxy 8080:80  &> /dev/null &  

desc "Be sure to use localhost:8080 since running dex local"
desc "Everything properly port-forwarded!"
desc ""
read -s
desc "Before we continue, go see the app on localhost"
desc "http://localhost:8080/"
desc "http://localhost:8080/ui"
desc "http://localhost:8080/httpbin"
read -s
backtotop

desc "Set up dex oidc in gloo ext auth"
run "cat dex-oidc-authconfig.yaml"
run "kubectl apply -f dex-oidc-authconfig.yaml"


desc "Update virtual service with OIDC config"
run "cat dex-oidc-vs.yaml"
run "kubectl apply -f dex-oidc-vs.yaml"

desc "go check page now: http://localhost:8080"
desc "Login in admin@example.com :: password"
