#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD

kubectl -n glooshot port-forward deployment/glooshot-prometheus-server 9090 &> /dev/null &

# may also be interesting to slowly introduce the prometheus query we are using:
# https://prometheus.io/docs/prometheus/latest/querying/functions/#rate
#
#
# Try first with this query:
# istio_requests_total{ source_app="productpage",response_code="500",reporter="destination",destination_app="reviews",destination_version!="v1"}

# rate(istio_requests_total{ source_app="productpage",response_code="500",reporter="destination",destination_app="reviews",destination_version!="v1"}[1m])

# scalar(sum(rate(istio_requests_total{ source_app="productpage",response_code="500",reporter="destination",destination_app="reviews",destination_version!="v1"}[1m])))


desc "Let's run a chaos experiment"
desc "First, let's take a look at the definition of the experiment"
run "cat $(relative resources/experiment.yaml)"

backtotop
desc "Let's take a look at prometheus"
open http://localhost:9090

backtotop

read -s
desc "Let's apply the experiment"
run "kubectl apply -f $(relative resources/experiment.yaml)"

desc "Now go get some load"
desc "May also want to check Prom"
read -s

backtotop

desc "Let's see the status of the experiment after the run"
run "kubectl get exp -n bookinfo abort-ratings-metric -o yaml"
run "kubectl get reports -n bookinfo abort-ratings-metric -o yaml"

backtotop

desc "Route to more resilient example"
run "kubectl apply -f $(relative resources/reviews-100-v3-resilient.yaml)"

desc "Let's run the experiment again"
run "cat $(relative resources/experiment-repeat.yaml)"

run "kubectl apply -f $(relative resources/experiment-repeat.yaml)"
backtotop

desc "Now check out the product page"
desc "Note that just the reviews part fails"
read -s

desc "Let's take a look:"
run "kubectl get exp -n bookinfo abort-ratings-metric-repeat -o yaml"