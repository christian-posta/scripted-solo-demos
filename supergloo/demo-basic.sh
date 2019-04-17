#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD

desc "Installing Istio with simple comamnd"
run "supergloo install istio --name istio-demo"
run "kubectl get installs istio-demo -n supergloo-system -o yaml"
run "kubectl get pod -w -n istio-system"
backtotop



desc "Install the Istio bookinfo demo"
run "kubectl label --overwrite=true namespace default istio-injection=enabled"
run "kubectl apply -n default -f https://raw.githubusercontent.com/istio/istio/1.0.6/samples/bookinfo/platform/kube/bookinfo.yaml"
run "kubectl get pod -w"
backtotop

desc "Install Gloo Gateway"
run "supergloo install gloo --name gloo --target-meshes supergloo-system.istio-demo"
run "kubectl get installs gloo -n supergloo-system -o yaml"
run "kubectl get pod -n gloo-system -w"
backtotop


desc "Let's hook up the mTLS to the upstream"
run "supergloo set upstream mtls --name  default-productpage-9080 --target-mesh supergloo-system.istio-demo"
backtotop

desc "Let's try create a route to the productpage"
run "glooctl add route --path-prefix / --dest-name default-productpage-9080 --dest-namespace supergloo-system"
desc "Now go to this URL to see the productpage demo:"
run "glooctl proxy url"