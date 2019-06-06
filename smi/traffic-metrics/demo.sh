#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

SOURCE_DIR=$PWD

desc "Installing linkerd"
run "linkerd install | kubectl apply -f -"
run "linkerd check"

desc "Install the smi-metrics adapter"
run "kubectl apply -f $(relative smi-metrics-adapter.yaml)"

desc "Install the linkerd emoji app"
run "curl -sL https://run.linkerd.io/emojivoto.yml | linkerd inject  - | kubectl apply -f -"
run "kubectl get pod -w -n emojivoto"

desc "Check stats"
run "watch linkerd -n emojivoto stat deploy"

desc "Let's get metrics from the Kube API"
read -s

tmux split-window -v -d -c $SOURCE_DIR
tmux select-pane -t 0
tmux send-keys -t 1 "kubectl proxy" C-m


run "curl http://localhost:8001/apis/metrics.smi-spec.io/v1alpha1 | pretty-json"

run "curl http://localhost:8001/apis/metrics.smi-spec.io/v1alpha1/deployments | pretty-json"
run "curl http://localhost:8001/apis/metrics.smi-spec.io/v1alpha1/pods | pretty-json"

desc "cleanup"
tmux send-keys -t 1 C-c
tmux send-keys -t 1 "exit" C-m