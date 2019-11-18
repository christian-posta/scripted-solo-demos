#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh


SOURCE_DIR=$PWD
export GOPRIVATE=github.com/solo-io/autopilot

pushd autorouter > /dev/null 2>&1

desc "Auto pilot demo, part 3!"
read -s

desc "Let's build our project now with the updated workers and spec file"
run "go build cmd/autoroute-operator/main.go"
run "ap build ceposta/autorouter:v0.2"
run "docker images | head -n 5"


desc "Now let's deploy it, telling ap to delete the old operator"
run "ap deploy ceposta/autorouter:v0.2 -d -p"
run "kubectl get po -n autoroute-operator"

backtotop
read -s

desc "Let's watch the logs for the controller"
POD=$(kubectl get po -n autoroute-operator | grep auto | awk '{print $1}')
tmux split-window -v -d -c $SOURCE_DIR
tmux select-pane -t 0
tmux send-keys -t 1 C-l
tmux send-keys -t 1 "kubectl logs -n autoroute-operator -f $POD" C-m

read -s
desc "Now let's deploy a new kubernetes deployment"
run "kubectl apply -f ../resources/echo-deploy.yaml -n default"

desc "Let's create the CRD and watch what happens:"
run "kubectl apply -f deploy/autoroute_example.yaml"

desc "Did we create all of the right resources?"
run "kubectl get service"
run "kubectl get gateway -o yaml"
run "kubectl get virtualservice -o yaml"

desc "Clean up"
read -s
# cleanup
tmux send-keys -t 1 C-c
tmux send-keys -t 1 "exit" C-m