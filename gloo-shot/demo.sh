#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD

desc "Let's run a chaos experiment"
run "cat $(relative resources/experiment.yaml)"
backtotop

run "kubectl apply -f $(relative resources/experiment.yaml)"

desc "Now go get some load"
desc "May also want to check Prom"
read -s

desc "Let's see the status of the experiment after the run"
run "kubectl get exp -n bookinfo abort-ratings-metric -o yaml"
run "kubectl get reports -n bookinfo abort-ratings-metric -o yaml"

backtotop

desc "delete existing routing rule"
run "kubectl delete routingrule -n bookinfo reviews-vulnerable"

backtotop
desc "Route to more resilient example"
run "supergloo apply routingrule trafficshifting \
    --namespace bookinfo \
    --name reviews-resilient \
    --dest-upstreams glooshot.bookinfo-reviews-9080 \
    --target-mesh glooshot.istio-istio-system \
    --destination glooshot.bookinfo-reviews-v3-9080:1"

backtotop

desc "Let's run the experiment again"
run "cat $(relative resources/experiment-repeat.yaml)"
backtotop

run "kubectl apply -f $(relative resources/experiment-repeat.yaml)"

desc "Now check out the product page"
desc "Note that just the reviews part fails"
read -s

desc "Let's take a look:"
run "kubectl get exp -n bookinfo abort-ratings-metric-repeat -o yaml"