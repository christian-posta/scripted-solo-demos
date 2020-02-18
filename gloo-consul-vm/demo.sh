#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD


desc "Go to Consul UI"
echo "http://localhost:8500/ui"
read -s

desc "Let's add a service to  Consul"
#curl -v  -XPUT --data @petstore-service.json  "http://127.0.0.1:8500/v1/agent/service/register"
run "curl -v  -XPUT --data @petstore-service.json  \"http://127.0.0.1:8500/v1/agent/service/register\""

run "consul catalog services"

run "glooctl --use-consul get upstream"


desc "Now let's add to the pestore API to Gloo"
run "glooctl --use-consul add route --path-exact /all-pets --dest-name petstore --prefix-rewrite /api/pets"

run "glooctl --use-consul get virtualservice"

desc "Go look at Consul UI in the K/V section for the newly added config"
read -s


desc "Now curl the service"
run "curl http://localhost:8080/all-pets"


