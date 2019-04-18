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

desc "Let's add an abort fault rule"
run "supergloo apply routingrule faultinjection abort http \
    --target-mesh supergloo-system.istio \
     -p 50 -s 404  --name rule1 \
    --dest-upstreams supergloo-system.default-reviews-9080"

desc "Lets take a look at the RoutingRule that was created to support this"
run "kubectl get routingrule -n supergloo-system rule1 -o yaml"

desc "Let's introduce a delay this time"
run "supergloo apply routingrule faultinjection delay fixed \
    --target-mesh supergloo-system.istio \
     -p 50 -d 5s  --name rule1 \
    --dest-upstreams supergloo-system.default-reviews-9080"

run "kubectl get routingrule -n supergloo-system rule1 -o yaml"

desc "Cleanup"
run "kubectl delete routingrules rule1 -n supergloo-system"