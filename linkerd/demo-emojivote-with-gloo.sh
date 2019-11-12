#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD



desc "Make sure Linkerd and emojivoto is installed"
read -s

# https://docs.solo.io/gloo/latest/gloo_integrations/service_mesh/gloo_linkerd/
desc "Let's update Gloo to automiatcally place nicely wiht linkerd"
run "kubectl patch settings -n gloo-system default -p '{\"spec\":{\"linkerd\":true}}' --type=merge"

desc "Now we should be able to automatically route to emojivoto web app"
run "glooctl add route --path-prefix=/ --dest-name emojivoto-web-svc-80"

desc "Now navigate to:"
run "glooctl proxy url"
