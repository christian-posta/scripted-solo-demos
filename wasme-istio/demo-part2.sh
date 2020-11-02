#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD
#GLOOCTL=$(relative bin/glooctl)
#WASME=$(relative bin/wasme)
GLOOCTL=glooctl
WASME=wasme


CURRENT_BUILD=$(wasme list | grep ceposta/demo-add-header | awk '{ print $2}' | cut -d '.' -f 2 | sort -nr | head -n 1)
# We shouldn't add +1 to this because that was already done in the previous demo
#DEMO_BUILD_NUMBER=$CURRENT_BUILD
DEMO_BUILD_NUMBER=$CURRENT_BUILD

# wasme deploy
desc "Now let's deploy the demo-add-header:v0.${DEMO_BUILD_NUMBER:-1} wasm module to istio"
read -s

desc "Recall our service response from productpage to details"
run "kubectl exec -it -n bookinfo deploy/productpage-v1 -c istio-proxy -- curl -v http://details.bookinfo:9080/details/123"

backtotop
desc "We will deploy the module to Istio with the wasme deploy istio command"
read -s

# wasme deploy istio webassemblyhub.io/ceposta/demo-add-header:v0.2 --id=myfilter  --namespace=bookinfo  --config 'tomorrow'

# wasme deploy istio webassemblyhub.io/ceposta/demo-add-header:v0.2 --id=myfilter  --namespace=bookinfo  --config 'tomorrow' --labels app=details'

run "wasme deploy istio webassemblyhub.io/ceposta/demo-add-header:v0.${DEMO_BUILD_NUMBER:-1} --id=myfilter --namespace=bookinfo --config 'tomorrow'"

backtotop
desc "Let's see the control plane resources we created"
read -s

run "kubectl get envoyfilter -n bookinfo"
run "kubectl get envoyfilter productpage-v1-myfilter -n bookinfo -o yaml"
run "kubectl get po -n bookinfo"

backtotop
desc "Let's make the call from productpage -> details"
read -s

run  "kubectl exec -it -n bookinfo deploy/productpage-v1 -c istio-proxy -- curl -v http://details.bookinfo:9080/details/123"


#desc "We can add multiple instances of our filter, with a different id and configuration"
#run "wasme deploy istio webassemblyhub.io/ceposta/demo-add-header:v0.${DEMO_BUILD_NUMBER:-1} --id=myfilter2 --namespace=bookinfo --config 'yesterday'"
#run  "kubectl exec -it -n bookinfo deploy/productpage-v1 -c istio-proxy -- curl -v http://details.bookinfo:9080/details/123"


desc "Clean up"
run "wasme undeploy istio --id myfilter --namespace bookinfo"
#run "wasme undeploy istio --id myfilter2 --namespace bookinfo"
