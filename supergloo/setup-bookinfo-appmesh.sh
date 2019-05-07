#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh


tmux split-window -v -d -c $SOURCE_DIR
tmux select-pane -t 0
tmux send-keys -t 1 "kubectl get pod -n bookinfo-appmesh" C-m


kubectl apply -f $(relative appmesh/bookinfo.yaml) -n bookinfo-appmesh
