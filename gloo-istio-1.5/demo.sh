#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD

desc "We have Istio Installed"
run "kubectl get po -n istio-system"

desc "We have Gloo Installed"
run "kubectl get po -n gloo-system"

desc "We have bookinfo with istio sidecars"
run "kubectl get po -n bookinfo"

backtotop
desc "Lets use Gloo to allow traffic into the cluster"
read -s

run "glooctl add route --name default --path-prefix / --dest-name bookinfo-productpage-9080"
run "watch -n 3 glooctl get vs"

desc "Now try go to productpage through Gloo"
run "glooctl proxy url"

desc "Go to that URL in firefox"
read -s

backtotop
desc "Let's configure Gloo to use Istio SDS"
read -s

run "cat resources/gateway-proxy-deploy-sds.yaml"

backtotop
desc "Apply the settings"
read -s

run "kubectl apply -f resources/gateway-proxy-deploy-sds.yaml"

backtotop
desc "Let's configure the upstream connection to Istio to use SDS"
read -s

run "cat resources/productpage-upstream.yaml"

desc "Apply the settings"
run "kubectl apply -f resources/productpage-upstream.yaml"

desc "Let's configre gloo to route to this mtls enabled upstream"
run "kubectl apply -f resources/productpage-mtls-vs.yaml"


desc "Let's capture the traffic between Gloo and ProductPage"
read -s 

PRODUCT_PAGE_IP=$(kubectl get pod -o wide -n bookinfo | grep productpage | awk '{ print $6 }')
GLOO_POD=$(kubectl get pod -l gloo=gateway-proxy -n gloo-system -o jsonpath={.items..metadata.name})

# split the screen and run the polling script in bottom script
tmux split-window -v -d -c $SOURCE_DIR
tmux select-pane -t 0
tmux send-keys -t 1 "kubectl sniff -i eth0 -o $(relative pcap/capture1.pcap) $GLOO_POD -n gloo-system -f '((tcp) and (net $PRODUCT_PAGE_IP))'" C-m


backtotop
desc "Now check that the connection proceeds"
read -s
