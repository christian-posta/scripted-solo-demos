#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

desc "Query Consul to make sure we can access it"
run "consul members -http-addr $(glooctl proxy url)"

desc "Query available services"
run "consul catalog services -http-addr $(glooctl proxy url)"

desc "Let's add a service to json placeholder"
run "cat $(relative consul/jsonplaceholder.json)"
run "consul services register -http-addr $(glooctl proxy url)  $(relative consul/jsonplaceholder.json)"


desc "Query available services"
run "consul catalog services -http-addr $(glooctl proxy url)"

desc "Let's configure Gloo to discover upstreams from the consul server"
run "kubectl get settings default -n gloo-system"

backtotop
desc "give a moment for discovery to kick in"
read -s

desc "Get upstreams, grep by Consul"
run "glooctl get upstream | grep Consul"
run "glooctl get upstream jsonplaceholder"
run "glooctl get upstream jsonplaceholder -o yaml"

backtotop

desc "Let's route to this new upstream"
run "cat $(relative default-vs-jsonplaceholder.yaml)"
run "kubectl apply -f default-vs-jsonplaceholder.yaml"

backtotop

desc "Now let's call to /todos"
run "curl $(glooctl proxy url)/todos"

# clean up
# kubectl patch settings default -n gloo-system --type json  --patch "$(cat ./consul/settings-patch-delete.json)"
