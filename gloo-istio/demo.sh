#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD

echo "Make sure Gloo is installed"
read -s

desc "We have Istio Installed"
run "kubectl get po -n istio-system"

desc "We have Gloo Installed"
run "kubectl get po -n gloo-system"

desc "And we have the bookinfo sample app installed"
run "kubectl get po -n bookinfo"

desc "Let's integrate Gloo with Istio"
desc "First let's see that we can get to the bookinfo app"
read -s

# First do a port forward


tmux split-window -v -d -c $SOURCE_DIR
tmux select-pane -t 0
tmux send-keys -t 1 C-l
tmux send-keys -t 1 "kubectl port-forward svc/productpage  -n bookinfo  8080:9080" C-m

# open locally
desc "View the bookinfo app on firefox"
read -s
/Applications/Firefox.app/Contents/MacOS/firefox --new-tab  localhost:8080

backtotop


read -s
tmux send-keys -t 1 C-c
tmux send-keys -t 1 "exit" C-m

read -s
desc "Lets use Gloo to allow traffic into the cluster"
run "glooctl add route --name default --path-prefix / --dest-name bookinfo-productpage-9080"
run "watch -n 3 glooctl get vs"

desc "Now try go to productpage through Gloo"
run "glooctl proxy url"

desc "Go to that URL in firefox"
read -s

backtotop

desc "Let's configure Gloo to use Istio SDS"
run "cat resources/gateway-proxy-deploy-sds.yaml"

desc "Check out the settings"
read -s

desc "Apply the settings"
run "kubectl apply -f resources/gateway-proxy-deploy-sds.yaml"

backtotop

desc "Let's configure the upstream connection to Istio to use SDS"
run "cat resources/productpage-upstream-sds.yaml"

desc "Check the settings"
read -s

desc "Apply the settings"
run "kubectl apply -f resources/productpage-upstream-sds.yaml"

# run behind the scenes; this is to kick envoy to correctly pick up the SDS
kubectl delete pod -l gloo=gateway-proxy -n gloo-system  > /dev/null 2>&1

desc "Now check that the connection proceeds"
read -s


