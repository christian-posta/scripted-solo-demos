#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh
. ../.env.sh

desc "Configure default vs to expose consul service"
run "kubectl apply -f default-vs-consul.yaml"
export CONSUL_HTTP_ADDR="ceposta-gloo-demo.solo.io"
desc "Query Consul to make sure we can access it"
run "consul members"
#old way: -http-addr $(glooctl proxy url)

desc "Query available services"
run "consul catalog services"

desc "Let's add a service to json placeholder"
run "cat $(relative consul/jsonplaceholder.json)"
run "consul services register  $(relative consul/jsonplaceholder.json)"


desc "Query available services"
run "consul catalog services"

desc "Let's configure Gloo to discover upstreams from the consul server"
run "kubectl patch settings default -n gloo-system --type merge --patch '$(cat ./consul/settings-patch.yaml)'"
run "kubectl get settings default -n gloo-system -o yaml"

backtotop
desc "give a moment for discovery to kick in"
read -s

desc "Get upstreams, grep by Consul"
run "glooctl get upstream | grep Consul"
run "glooctl get upstream jsonplaceholder"

backtotop

desc "Let's route to this new upstream"
run "cat $(relative default-vs-jsonplaceholder.yaml)"
run "kubectl apply -f default-vs-jsonplaceholder.yaml"

backtotop

desc "Now let's call to /todos"
run "curl http://$DEFAULT_DOMAIN_NAME/todos"


