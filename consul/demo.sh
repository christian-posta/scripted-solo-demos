#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD



kubectl port-forward -n consul-system service/gloo-consul-ui  18500:80 &> /dev/null &  
PF_PID=$!

export CONSUL_HTTP_ADDR="http://localhost:18500"
desc "Go to Consul UI"
echo "http://localhost:8500/ui"
read -s

run "consul catalog services"

echo "Cleaning up"
kill -9 $PF_PID