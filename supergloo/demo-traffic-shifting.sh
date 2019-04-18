#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD

desc "Requires bookinfo installed"
read -s

if [ "$1" != "skip" ]; then 
    tmux split-window -v -d -c $SOURCE_DIR
    tmux select-pane -t 0
    tmux send-keys -t 1 "kubectl port-forward -n default deploy/productpage-v1 9080" C-m

    desc "Installing Istio with simple comamnd"
    run "open http://localhost:9080/productpage"
fi

desc "Let's add some traffic-control rules"
run "supergloo apply routingrule trafficshifting \
    --name reviews-v3 \
    --dest-upstreams supergloo-system.default-reviews-9080  \
    --target-mesh supergloo-system.istio \
    --destination supergloo-system.default-reviews-v1-9080:1"

desc "Lets take a look at the RoutingRule that was created to support this"
run "kubectl get routingrule -n supergloo-system reviews-v3 -o yaml"

desc "Lets split traffic 50:50 between version reviews-v2 and reviews-v3"
run "supergloo apply routingrule trafficshifting \
    --name reviews-v3 \
    --dest-upstreams supergloo-system.default-reviews-9080 \
    --target-mesh supergloo-system.istio \
    --destination supergloo-system.default-reviews-v2-9080:1 \
    --destination supergloo-system.default-reviews-v3-9080:1"

run "supergloo apply routingrule trafficshifting \
    --name reviews-v3 \
    --dest-upstreams supergloo-system.default-reviews-9080  \
    --target-mesh supergloo-system.istio \
    --destination supergloo-system.default-reviews-v3-9080:1"    

desc "Lets review the upstreams"
run "kubectl get upstream -n supergloo-system default-reviews-9080 -o json | jq .spec.upstreamSpec"

desc "Reviews v3"
run "kubectl get upstream -n supergloo-system default-reviews-v3-9080 -o json | jq .spec.upstreamSpec"

desc "All upstreams"
run "kubectl get upstream -n supergloo-system"

desc "Cleanup"
run "kubectl delete routingrules reviews-v3 -n supergloo-system"