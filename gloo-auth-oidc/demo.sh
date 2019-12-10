#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD


desc "What services do we have running here?"
run "kubectl get po -n default"

desc "We've deployed Envoy and the Gloo control plane"
run "kubectl get po -n gloo-system"

desc "Gloo has a nice management UI for Envoy and the control plane"
run "open http://localhost:8080"

desc "Let's set up a route to bookinfo"
run "glooctl add route --path-prefix=/ --dest-name default-productpage-9080"

desc "Now navigate to:"
run "glooctl proxy url"

desc "We can see metrics:"


desc "Let's add Auth0 OIDC integration"
run "cat gloo-oidc-auth0.yaml"

desc "Note, we can use glooctl, or we can use kubectl directly"
run "kubectl apply -f gloo-oidc-auth0.yaml"
