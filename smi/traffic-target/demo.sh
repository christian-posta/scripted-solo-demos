#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

SOURCE_DIR=$PWD

desc "Deploying sample apps"
desc "First deploy the service accounts (used for identity in this example)"
run "kubectl apply -f $(relative resources/serviceaccount.yaml)"

desc "Deploy the apps and watch for auto sidecar injection"
run "kubectl apply -f $(relative resources/backend.yaml)"
run "kubectl apply -f $(relative resources/frontend.yaml)"

desc "Now let's create some TrafficTarget rules"
run "kubectl apply -f $(relative traffic-spec.yaml)"
run "cat  $(relative traffic-target.yaml)"
run "kubectl apply -f $(relative traffic-target.yaml)"