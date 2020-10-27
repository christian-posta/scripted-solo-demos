#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

desc "Basic routing demo"
run "kubectl get virtualservice -n gloo-system -o yaml"
run "glooctl get virtualservice"

desc "Get the url"
run "glooctl proxy url"
URL=$(glooctl proxy url)

desc "Call the API:"
run "curl $URL"

desc "Try the browser as well"
echo "$URL/ui"
