#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD


export GOPRIVATE=github.com/solo-io/autopilot

desc "Auto pilot demo!"
desc "Let's create a new autopilot project based on the autorouter tutorial"
read -s

desc "First, let's init a project"
run "ap init autorouter --kind AutoRoute --group examples.io --version v1 --module autorouter.example.io"
run "tree autorouter && cd autorouter"

desc "Let's see what files were created!"
run "code ."

backtotop

desc "Press Enter to edit the autopilot.yaml"
read -s
cp ../resources/autopilot.yaml .

desc "Now check out the new phases that were added to the autopilot.yaml"
desc "Press Enter to generate the code"
read -s

run "ap generate"

desc "Now explore your new code base"
read -s

backtotop

desc "Now let's build the project as it is. "
read -s
run "ap build ceposta/autorouter:v0.1"
run "docker images | head -n 5"

desc "Now let's deploy"
run "ap deploy -p ceposta/autorouter:v0.1"
run "kubectl get ns"
run "kubectl get po -n autoroute-operator"

desc "Let's watch the logs for the controller"
POD=$(kubectl get po -n autoroute-operator | grep auto | awk '{print $1}')

tmux split-window -v -d -c $SOURCE_DIR
tmux select-pane -t 0
tmux send-keys -t 1 C-l
tmux send-keys -t 1 "kubectl logs -n autoroute-operator -f $POD" C-m

backtotop

desc "Let's create the CRD and watch what happens:"
read -s
run "cat deploy/autoroute_example.yaml"
run "kubectl apply -f deploy/autoroute_example.yaml"
read -s

desc "Clean up"
read -s
desc "let's delete the autoroute_example.yaml so we don't get into a crash-loop"
run "kubectl delete -f deploy/autoroute_example.yaml"
# cleanup
tmux send-keys -t 1 C-c
tmux send-keys -t 1 "exit" C-m
