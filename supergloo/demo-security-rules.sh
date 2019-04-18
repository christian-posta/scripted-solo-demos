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

desc "Let's create a basic SecurityRule to blacklist all traffic"
run "supergloo apply securityrule \
    --name enable-security \
    --namespace default \
    --source-upstreams supergloo-system.default-productpage-9080 \
    --dest-upstreams supergloo-system.default-productpage-9080 \
    --target-mesh supergloo-system.istio"
run "kubectl get securityrule enable-security -n default -o yaml"


desc "Now go check that we cannot reach details or reviews"
read -s
backtotop

desc "Now let's whitelist traffic from productpage->details"
run "supergloo apply securityrule \
    --name productpage-to-details \
    --namespace default \
    --source-upstreams supergloo-system.default-productpage-9080 \
    --dest-upstreams supergloo-system.default-details-9080 \
    --target-mesh supergloo-system.istio"
run "kubectl get securityrule productpage-to-details -n default -o yaml"


desc "Now go check that we can reach details but not reviews"
read -s
backtotop

desc "Since reviews, ratings, details, etc live in the same namespace, let's just create a rule to allow any traffic within the namespace"
run "supergloo apply securityrule \
    --name enable-security \
    --namespace default \
    --source-upstreams supergloo-system.default-productpage-9080 \
    --dest-namespaces default \
    --target-mesh supergloo-system.istio"


  desc "Let's clean up these rules"
  run "kubectl delete securityrule -n default --all"