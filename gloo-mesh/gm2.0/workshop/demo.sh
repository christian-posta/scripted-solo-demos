#!/bin/bash

. $(dirname ${BASH_SOURCE})/util.sh

source ./env-workshop-bare.sh


export GATEWAY_IP="$(kubectl --context $CLUSTER1 get svc -n istio-gateways | grep ingress | awk '{print $4}')"

backtotop
desc "Let's create a tenant/workspace to contain service policy"
read -s


run "cat ./bare/workspace-gateways.yaml"
run "kubectl --context $MGMT apply -f ./bare/workspace-gateways.yaml"

run "cat ./bare/workspace-settings-gateway.yaml"
run "kubectl --context $CLUSTER1 apply -f ./bare/workspace-settings-gateway.yaml"

backtotop
desc "Let's do the same thing for the bookinfo team"
read -s

run "cat ./bare/workspace-bookinfo.yaml"
run "kubectl --context $MGMT apply -f ./bare/workspace-bookinfo.yaml"
run "kubectl --context $CLUSTER1 apply -f ./bare/workspace-settings-bookinfo.yaml"

backtotop
desc "Virtual Destinations"
read -s

run "cat ./bare/virtualdestination.yaml"
run "kubectl --context $CLUSTER1 apply -f ./bare/virtualdestination.yaml"
# Need to add some commands 
run "kubectl --context $CLUSTER1 exec -it deploy/sleep -n gloo-mesh-addons -c sleep -- curl http://productpage.gloo-mesh.istiodemos.io:9080/productpage"

backtotop
desc "Now we can continue to configure various aspects of routing across the clusters for our bookinfo tenant and gateway tenant"
desc "Like a Virtual Gateway / Gloo Mesh Gateway / API Gateway:"
read -s

desc "Note that the virtual gateway is owned by the gateway team"
run "cat ./bare/virtualgateway.yaml"

desc "Note that the routing is owned by the bookinfo table and exported to the gateway tenant"
run "cat ./bare/routetable.yaml"

run "kubectl --context $CLUSTER1 apply -f ./bare/virtualgateway.yaml -f ./bare/routetable.yaml"

desc "We should be able to call the gateway successfully now for bookinfo productpage"
# Need to add run command here.....
run "kubectl --context $CLUSTER1 get svc -n istio-gateways"
run "curl -k https://$GATEWAY_IP/productpage"


