#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD

desc "Let's take a look at the upstreams we have:"
run "kubectl get pod"

tmux split-window -v -d -c $SOURCE_DIR
tmux select-pane -t 0
tmux send-keys -t 1 "kubectl port-forward deploy/example-service1 8080" C-m
read -s
backtotop

desc "Let's open the calc app"
run "open http://localhost:8080"

desc "Go to code and debug example-service1"
read -s


JAVA_POD=$(kubectl get pod | grep java | awk '{ print $1 }')

desc "Let's open port-forwarding for the java service"
run "squashctl --localport 5005"