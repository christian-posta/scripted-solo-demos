#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

SOURCE_DIR=$PWD

desc "First we want to have a steady-state routing definition and give v1 all the weight for routing"
run "kubectl get pod -n smi-demo"
run "cat $(relative resources/02-traffic-split-1000-0.yaml)"
backtotop

desc "Now let's apply this traffic splitting definition"
run "kubectl -n smi-demo apply -f $(relative resources/02-traffic-split-1000-0.yaml)"
run "kubectl -n smi-demo get trafficsplit"
run "kubectl -n smi-demo get virtualservices.networking.istio.io"
run "kubectl -n smi-demo get virtualservices.networking.istio.io reviews-rollout-vs -o yaml"
backtotop

desc "Now let's deploy v2 of reviews"
run "kubectl -n smi-demo apply -f $(relative resources/03-deploy-v2.yaml)"

desc "Go back and check all traffic still goes to v1"
read -s
backtotop

desc "Let's do a minimal release to 10% of users"
desc "We'll direct 10% of traffic to v2"
run "cat resources/04-traffic-split-900-100.yaml"
run "kubectl -n smi-demo apply -f resources/04-traffic-split-900-100.yaml"

desc "Now let's roll out 25% of traffic"
run "kubectl -n smi-demo apply -f resources/05-traffic-split-750-250.yaml"

desc "Go check it"
read -s
backtotop

desc "If everything looks good, let's roll out all the traffic to v2"
run "cat resources/07-traffic-split-0-1000.yaml"
run "kubectl -n smi-demo apply -f resources/07-traffic-split-0-1000.yaml"

desc "Now if we're confident we are set with v2 taking all the load, clean up the v1 deploy and traffic defs"
run "kubectl -n smi-demo delete -f resources/01-deploy-v1.yaml"
run "kubectl -n smi-demo delete trafficsplit reviews-rollout"