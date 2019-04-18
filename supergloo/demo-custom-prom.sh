#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD

desc "Lets create a prometheus server"
run "kubectl create ns prometheus-test"
run "kubectl apply -n prometheus-test -f \
  https://raw.githubusercontent.com/solo-io/solo-docs/master/supergloo/examples/prometheus/prometheus-demo.yaml"
run "kubectl get pod -n prometheus-test -w"

run "kubectl get configmap -n prometheus-test"
run "kubectl get configmap prometheus-server -n prometheus-test -o yaml"
backtotop

desc "Lets let the mesh know about this prom so it can add scrape jobs"
run "supergloo set mesh stats \
  --target-mesh supergloo-system.istio \
  --prometheus-configmap prometheus-test.prometheus-server"
backtotop

desc "We can also see that it's been added to our Mesh CRD"
run "kubectl get mesh -n supergloo-system istio -o yaml"

desc "Lets see what it added"
run "kubectl get configmap -n prometheus-test -o yaml | grep istio"

backtotop

desc "Lets review the stats in prom"
tmux split-window -v -d -c $SOURCE_DIR
tmux select-pane -t 0

tmux send-keys -t 1 "kubectl port-forward -n prometheus-test deployment/prometheus-server 9090" C-m
read -s


desc "Take a look at the following metrics:"
desc "istio_requests_total"
desc "istio_requests_total{destination_app=\"reviews\"}"
read -s

run "kubectl port-forward -n default deploy/productpage-v1 9080" 