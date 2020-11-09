#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh
. ../.env.sh
DIR=$(dirname ${BASH_SOURCE})
# reset the settings file because we'll use the Gloo RateLimitConfig crd
kubectl patch settings default -n gloo-system --type json  --patch "$(cat $DIR/config/settings-patch-delete.json)" &> /dev/null

desc "We are going to use RateLimitConfig in this demo instead of embed directly"
desc "into the VS or settings yaml"
run "cat $DIR/config/rate-limit-config-headers.yaml"
run "kubectl apply -f $DIR/config/rate-limit-config-headers.yaml"

backtotop
desc "Now we need to add to the VS"
read -s
run "cat $DIR/config/default-vs-rate-limit.yaml"
run "kubectl apply -f $DIR/config/default-vs-rate-limit.yaml"

backtotop
desc "Try call with different types"
read -s

desc "With Messenger"
run "for i in {1..4}; do curl -I https://ceposta-gloo-demo.solo.io/httpbin -H \"x-type: Messenger\";  done"

desc "With Whatsapp"
run "for i in {1..3}; do curl -I https://ceposta-gloo-demo.solo.io/httpbin -H \"x-type: Whatsapp\";  done"

desc "With Whatsapp and priority"
run "for i in {1..5}; do curl -I https://ceposta-gloo-demo.solo.io/httpbin -H \"x-type: Whatsapp\" -H \"x-number: 411\";  done"

desc "Anything else"
run "for i in {1..3}; do curl -I https://ceposta-gloo-demo.solo.io/httpbin -H \"x-type: Anything\";  done"
