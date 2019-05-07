#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD

tmux split-window -v -d -c $SOURCE_DIR
tmux select-pane -t 0
tmux send-keys -t 1 "stern -n supergloo-system supergloo" C-m


supergloo install linkerd --name linkerd
kubectl get pod -w -n linkerd

