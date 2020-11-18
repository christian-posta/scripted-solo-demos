#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh
. ../.env.sh

desc "Basic routing demo"
run "glooctl get virtualservice"

desc "Get the url"
run "glooctl proxy url"
URL=$(glooctl proxy url)

desc "Call the API:"
run "curl $URL"
run "curl http://$DEFAULT_DOMAIN_NAME"
run "curl http://$DEFAULT_DOMAIN_NAME/httpbin"

desc "Try the browser as well"
echo "http://$DEFAULT_DOMAIN_NAME/ui"
