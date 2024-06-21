#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh
SOURCE_DIR=$PWD



backtotop
desc "-----====Demo Istio with Sidecars ====-----"
read -s

desc "We have three apps: web-api, recommendation, purchase-history"
desc "(can go check things in k9s)"
read -s

backtotop
desc "Let's expose the web-api through the Istio ingress-gateway"
read -s

run "kubectl apply -f ./resources/istio/ingress-web-api.yaml"
GATEWAY_IP=$(kubectl get svc -n istio-system | grep ingressgateway | awk '{ print $4 }')
run "curl -H 'Host: istioinaction.io' http://$GATEWAY_IP/"

backtotop
desc "Let's add workloads to the mesh by injecting the sidecar"
read -s

run "kubectl label namespace default istio-injection=enabled && kubectl rollout restart deploy -n default"

run "kubectl label namespace web-api istio-injection=enabled &&kubectl rollout restart deploy -n web-api"

run "kubectl label namespace recommendation istio-injection=enabled && kubectl rollout restart deploy  -n recommendation"

run "kubectl label namespace purchase-history istio-injection=enabled && kubectl rollout restart deploy -n purchase-history"

desc "Let's add some load"
run "./call-web-api-load-gw.sh"

desc "Go check the metrics"
read -s

####################################
# add tracing
####################################

backtotop
desc "Let's add distributed tracing"
read -s

run "cat ./resources/istio/trace-sample-100.yaml"
run "kubectl apply -f ./resources/istio/trace-sample-100.yaml"

desc "Add some load"
run "./call-web-api-load-gw.sh 10"


####################################
# routing control
####################################

backtotop
desc "Controlling the routing to purchase-history"
read -s

run "cat ./resources/istio/purchase-history-header-v2.yaml"
run "kubectl apply -f ./resources/istio/purchase-history-header-v2.yaml"


desc "call the services from another terminal"
desc "(we will wait!)"
read -s

desc "Now let's call the services with the canary header"
run "curl -H 'x-test-routing: v2'  -H 'Host: istioinaction.io' http://$GATEWAY_IP/"


####################################
# policy
####################################

backtotop
desc "Let's lock down service calls with Policy enforcement and mutual authentication"
read -s

run "cat ./resources/istio/peerauth-strict.yaml"
run "kubectl apply -f ./resources/istio/peerauth-strict.yaml"

run "cat ./resources/istio/policy/deny-all.yaml "
run "kubectl apply -f ./resources/istio/policy/deny-all.yaml "

run "curl -H 'Host: istioinaction.io' http://$GATEWAY_IP/"

desc "We cannot call any services because we have a deny all"
desc "Let's adjust the policy"
read -s

backtotop
desc "Let's enable traffic to the ingress gateway and web-api"
read -s

run "cat ./resources/istio/policy/allow-ingress-to-web-api.yaml"
run "kubectl apply -f ./resources/istio/policy/allow-ingress-to-web-api.yaml"

run "curl -H 'Host: istioinaction.io' http://$GATEWAY_IP/"

desc "Getting closer!"
desc "Let's enable the allow policies for the other services"
read -s

run "kubectl apply -f resources/istio/policy/allow-web-api-to-recommendation.yaml "
run "kubectl apply -f resources/istio/policy/allow-recommendation-to-purchistory.yaml"

run "curl -H 'Host: istioinaction.io' http://$GATEWAY_IP/"

desc "But notice, we cannot call from the sleep service"
run "kubectl exec -it deploy/sleep -- curl -v http://web-api.web-api:8080/"

backtotop
desc "What about more fine-grained HTTP authz?"
read -s

run "kubectl exec -it deploy/sleep -- curl -v http://httpbin:8000/headers"
run "kubectl exec -it deploy/sleep -- curl -v http://httpbin:8000/ip"

desc "But we want to control which paths and how things get called"
read -s

run "cat ./resources/istio/policy/allow-sleep-to-httpbin.yaml"
run "kubectl apply -f ./resources/istio/policy/allow-sleep-to-httpbin.yaml"

run "kubectl exec -it deploy/sleep -- curl -v http://httpbin:8000/ip"
run "kubectl exec -it deploy/sleep -- curl -v -H 'x-test-me: approved' http://httpbin:8000/headers"

####################################
# jwt policy
####################################
backtotop
desc "Let's add a JWT policy to be able to call purchase history"
read -s

run "cat ./resources/istio/policy/request-authentication.yaml"
run "cat ./resources/istio/policy/allow-recommendation-to-purchase-history-jwt.yaml"

run "kubectl apply -f ./resources/istio/policy/request-authentication.yaml"
run "kubectl apply -f ./resources/istio/policy/allow-recommendation-to-purchase-history-jwt.yaml"

run "curl -H 'Host: istioinaction.io' http://$GATEWAY_IP/"

desc "Let's call it with the proper bearer token"
read -s

TOKEN=$(cat ./resources/istio/jwt/token.jwt)
run "curl -H 'Authorization: Bearer $TOKEN' -H 'Host: istioinaction.io' http://$GATEWAY_IP/"