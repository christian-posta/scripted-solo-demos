#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD
POD="foo"
tmux split-window -v -d -c $SOURCE_DIR
tmux select-pane -t 0
tmux send-keys -t 1 "useyard" C-m
tmux send-keys -t 1  C-l
tmux send-keys -t 1 "kubectl logs -n autoroute-operator -f $POD" C-m