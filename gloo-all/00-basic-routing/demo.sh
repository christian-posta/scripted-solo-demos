#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

desc "Basic routing demo"
run "cat default-vs.yaml"
run "kubectl apply -n gloo-system -f default-vs.yaml"

desc "Get the url"
run "glooctl proxy url"
URL=$(glooctl proxy url)

desc "Call the API:"
run "curl $URL"

desc "Try the browser as well"
echo "$URL/ui"
