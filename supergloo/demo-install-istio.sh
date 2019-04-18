#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD

tmux split-window -v -d -c $SOURCE_DIR
tmux select-pane -t 0
tmux send-keys -t 1 "stern -n supergloo-system supergloo" C-m

desc "Installing Istio with simple comamnd"
run "supergloo install istio --name istio"
run "kubectl get installs istio -n supergloo-system -o yaml"
run "kubectl get pod -w -n istio-system"
backtotop
