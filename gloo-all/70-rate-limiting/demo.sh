#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh
. ../.env.sh

desc "Let's start off by trying to rate limit by request ID"
run "curl https://$DEFAULT_DOMAIN_NAME/httpbin?show_env=1"

desc "Using descriptor chains (attribute matching)"
run "cat config/per-client-patch.yaml"
run "./apply-patch-settings.sh config/per-client-patch.yaml"

run "for i in {1..5}; do curl -I https://$DEFAULT_DOMAIN_NAME/httpbin;  done"

desc "Now we should see rate limit kick in:"
run "curl -I https://$DEFAULT_DOMAIN_NAME/httpbin"

desc "But we dont!!"
desc "We need to attach the descriptors/attributes to the request"
run "cat config/per-client-vs.yaml"
run "kubectl apply -f config/per-client-vs.yaml"

run "for i in {1..5}; do curl -I https://$DEFAULT_DOMAIN_NAME/httpbin;  done"

desc "Now we should see rate limit kick in:"
run "curl -I https://$DEFAULT_DOMAIN_NAME/httpbin"

backtotop
desc "We can do even more complicated nesting for rate limiting"
read -s

desc "Specify the rate limit descriptors"
run "cat config/per-client-per-secoond-patch.yaml"
run "./apply-patch-settings.sh config/per-client-per-second-patch.yaml"

desc "Specify the rate limit actions"
run "cat config/per-client-per-second-vs.yaml"
run "kubectl apply -f config/per-client-per-second-vs.yaml"

desc "Run some load"
run "fortio load -n 40  -c 3 -qps 3 -allow-initial-errors https://ceposta-gloo-demo.solo.io/httpbin"

desc "Lets run at the rate limit (2 qps)"
run "fortio load -n 50  -c 1 -qps 2 -allow-initial-errors https://ceposta-gloo-demo.solo.io/httpbin"

backtotop
desc "We can rate limit on any header!"
read -s

desc "Specify the rate limit descriptors"
run "cat config/per-http-method-patch.yaml"
run "./apply-patch-settings.sh config/per-http-method-patch.yaml"

desc "Specify the rate limit actions"
run "cat config/per-http-method-vs.yaml"
run "kubectl apply -f config/per-http-method-vs.yaml"

desc "GETs are limited"
run "for i in {1..3}; do curl -I -X GET https://$DEFAULT_DOMAIN_NAME/httpbin;  done"

desc "POSTs "
run "for i in {1..9}; do curl -I -X POST https://$DEFAULT_DOMAIN_NAME/httpbin/post;  done"
