#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

SOURCE_DIR=$PWD

desc "Canary analysis with Gloo and Flagger"
run "cat $(relative gloo-vs.yaml)"
run "kubectl apply -f $(relative gloo-vs.yaml)"
run "kubectl -n test get virtualservice "

desc "Define the canary parameters"
run "cat $(relative podinfo-canary.yaml)"
run "kubectl apply -f $(relative podinfo-canary.yaml)"
run "kubectl -n test get canary"
run "kubectl -n test get canary podinfo"

tmux split-window -v -d -c $SOURCE_DIR
tmux select-pane -t 0
tmux send-keys -t 1 "./bin/poll_gateway.sh" C-m