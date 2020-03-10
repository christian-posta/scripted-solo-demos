#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD
#GLOOCTL=$(relative bin/glooctl)
#WASME=$(relative bin/wasme)
WASME=wasme


CURRENT_BUILD=$(wasme list | grep ceposta/demo-add-header | awk '{ print $2}' | cut -d '.' -f 2 | sort -nr | head -n 1)
#DEMO_BUILD_NUMBER=$(($CURRENT_BUILD+1))
DEMO_BUILD_NUMBER=2


desc "We can even search from the cli:"
run "$WASME list --published --search ceposta"
backtotop

# wasme deploy
desc "Now let's deploy the wasm module to istio"
read -s

desc "Recall our service response from productpage to details"
run "kubectl exec -it -n bookinfo deploy/productpage-v1 -c istio-proxy -- curl -v http://details.bookinfo:9080/details/123"

backtotop

desc "We will deploy the module to Istio using the wasme operator"
read -s
run "kubectl get pod -n wasme"
backtotop

desc "Let's do the real deploy"
run "cat resources/filter-deployment.yaml"
run "kubectl apply -f resources/filter-deployment.yaml"

backtotop

desc "Let's see the control plane resources we created"
run "kubectl get envoyfilter -n bookinfo"
run "kubectl get envoyfilter productpage-v1-bookinfo-custom-filter.bookinfo  -n bookinfo -o yaml"

run "kubectl get po -n bookinfo"

desc "Let's make the call from productpage -> details"
run  "kubectl exec -it -n bookinfo deploy/productpage-v1 -c istio-proxy -- curl -v http://details.bookinfo:9080/details/123"


#desc "We can add multiple instances of our filter, with a different id and configuration"
#run "wasme deploy istio webassemblyhub.io/ceposta/demo-add-header:v0.${DEMO_BUILD_NUMBER:-1} --id=myfilter2 --namespace=bookinfo --config 'yesterday'"
#run  "kubectl exec -it -n bookinfo deploy/productpage-v1 -c istio-proxy -- curl -v http://details.bookinfo:9080/details/123"


desc "Clean up"
run "kubectl delete -f resources/filter-deployment.yaml"
