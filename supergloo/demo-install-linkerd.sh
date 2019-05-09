#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD

#tmux split-window -v -d -c $SOURCE_DIR
#tmux select-pane -t 0
#tmux send-keys -t 1 "stern -n supergloo-system supergloo" C-m

desc "Installing Linkerd with simple comamnd"
run "supergloo install linkerd --name linkerd"
run "kubectl get installs linkerd -n supergloo-system -o yaml"
run "kubectl get pod -w -n linkerd"
run "linkerd dashboard"
backtotop
