#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

kubectx gke-loop > /dev/null 2>&1

desc "Add route to Gloo for hello-v2 svc"
run "glooctl add route --name hello-v2 --namespace gloo-system --path-prefix / --prefix-rewrite /hello --dest-name hello-v2-helloworld-5000 --dest-namespace gloo-system"
