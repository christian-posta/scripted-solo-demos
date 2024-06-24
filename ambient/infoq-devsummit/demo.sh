#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh
SOURCE_DIR=$PWD


#####
##### This is the actual demo I did at infoq
#####


backtotop
desc "-----====Demo Istio ====-----"
desc "We have three apps: web-api, recommendation, purchase-history"
desc "(can go check things in k9s)"
read -s

backtotop
desc "Let's install Istio"
read -s

run "istioctl install -y -f ./resources/istio/install.yaml --set profile=ambient"

desc "Install the observability addons"
run "kubectl apply -f ~/dev/istio/istio-1.22.0/samples/addons/"

# need this so we can select "waypoint" reporter on grafana
kubectl apply -f ./resources/hack/grafana-waypoint.yaml > /dev/null 2>&1

desc "Go see what was installed"
read -s


backtotop
desc "Let's expose the web-api through the Istio ingress-gateway"
read -s

run "kubectl get svc -n istio-system"
GATEWAY_IP=$(kubectl get svc -n istio-system | grep ingressgateway | awk '{ print $4 }')
desc "Ingress gateway is a Load Balancer service with IP $GATEWAY_IP"
read -s 

run "cat ./resources/istio/ingress-web-api.yaml"
run "kubectl apply -f ./resources/istio/ingress-web-api.yaml"
run "curl -H 'Host: istioinaction.io' http://$GATEWAY_IP/"

backtotop
desc "Let's add workloads to the mesh by labeling the namespaces"
read -s

run "kubectl label namespace default istio.io/dataplane-mode=ambient"
run "kubectl label namespace web-api istio.io/dataplane-mode=ambient"
run "kubectl label namespace recommendation istio.io/dataplane-mode=ambient"
run "kubectl label namespace purchase-history istio.io/dataplane-mode=ambient"

desc "Thats it!! Our apps are part of the service mesh."
desc "Go check the metrics"
read -s

####################################
# policy
####################################

backtotop
desc "Let's lock down service calls with Policy enforcement"
read -s

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

run "cat ./resources/istio/policy/waypoint/allow-sleep-to-httpbin.yaml"

desc "Let's add a waypoint for the default namespace to add L7 policies"
run "istioctl x waypoint apply --enroll-namespace --for service --namespace default"


desc "Now let's add the authorization policies"
read -s

run "kubectl apply -f ./resources/istio/policy/waypoint/allow-sleep-to-httpbin.yaml"

desc "Now the correctly formed call to httpbin should work!"
run "kubectl exec -it deploy/sleep -- curl -v http://httpbin:8000/ip"
run "kubectl exec -it deploy/sleep -- curl -v -H 'x-test-me: approved' http://httpbin:8000/headers"




####################################
# routing control
####################################

backtotop
desc "Controlling the routing to purchase-history"
read -s

run "cat ./resources/istio/purchase-history-header-v2.yaml"

desc "Since we are going to use L7 policies (header, path, etc)"
desc "We need to deploy a waypoint proxy for purchase history"

run "istioctl x waypoint apply --enroll-namespace --for service --namespace purchase-history"
run "kubectl get po -n purchase-history"

run "kubectl apply -f ./resources/istio/purchase-history-header-v2.yaml"
run "kubectl apply -f ./resources/istio/policy/waypoint/allow-recommendation-to-purchistory.yaml"

GATEWAY_IP=$(kubectl get svc -n istio-system | grep ingressgateway | awk '{ print $4 }')
desc "call the service and JQ the output to show the body"
run "for i in {1..15} ; do curl -s -H 'Host: istioinaction.io' http://$GATEWAY_IP/  | jq .upstream_calls[].upstream_calls[].body ;  done"

desc "Now let's call the services with the canary header"
run "curl -H 'x-test-routing: v2'  -H 'Host: istioinaction.io' http://$GATEWAY_IP/"


####################################
# jwt policy
####################################
backtotop
desc "Let's add a JWT policy to be able to call purchase history"
read -s

run "cat ./resources/istio/policy/waypoint/request-authentication-purchase-history.yaml"
run "cat ./resources/istio/policy/waypoint/allow-recommendation-to-purchistory-jwt.yaml"

run "kubectl apply -f ./resources/istio/policy/waypoint/request-authentication-purchase-history.yaml"
run "kubectl apply -f ./resources/istio/policy/waypoint/allow-recommendation-to-purchistory-jwt.yaml"

run "curl -H 'Host: istioinaction.io' http://$GATEWAY_IP/"

desc "Let's call it with the proper bearer token"
read -s

TOKEN=$(cat ./resources/istio/jwt/token.jwt)
run "curl -H 'Authorization: Bearer $TOKEN' -H 'Host: istioinaction.io' http://$GATEWAY_IP/"

####################################
# add tracing
####################################

backtotop
desc "Let's add distributed tracing"
read -s

run "cat ./resources/istio/trace-sample-100.yaml"
run "kubectl apply -f ./resources/istio/trace-sample-100.yaml"

run "istioctl x waypoint apply --enroll-namespace --for service --namespace recommendation"
run "istioctl x waypoint apply --enroll-namespace --for service --namespace web-api"

desc "update policies to take recommendation and web-api waypoint into account"
run "kubectl apply -f ./resources/istio/policy/waypoint/allow-web-api-to-recommendation.yaml"
run "kubectl apply -f ./resources/istio/policy/waypoint/allow-sleep-to-web-api.yaml"


desc "Add some load"
run "./call-web-api-sleep-jwt.sh"