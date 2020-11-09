#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh
. ../.env.sh
DIR=$(dirname ${BASH_SOURCE})
# reset the settings file because we'll use the Gloo RateLimitConfig crd
kubectl patch settings default -n gloo-system --type json  --patch "$(cat $DIR/config/settings-patch-delete.json)" &> /dev/null

kubectl apply -f $DIR/config/rate-limit-config-headers.yaml &> /dev/null
kubectl apply -f $DIR/config/default-vs-rate-limit.yaml &> /dev/null


desc "In the previous demo, we saw how to use the rate limit config to"
desc "simplify adding rate limit settings and how to use headers to "
desc "specify rate limiting for a route"
read -s

desc "Let's use jwt and claims for the headers"
run "cat $DIR/config/default-vs-rate-limit-jwt.yaml"
run "kubectl apply -f $DIR/config/default-vs-rate-limit-jwt.yaml"

desc "With Messenger"
export TOKEN=$(cat config/messenger.jwt)
run "cat config/messenger.jwt | jwt"
run "for i in {1..4}; do curl -I https://ceposta-gloo-demo.solo.io/httpbin -H \"x-token: \$TOKEN\";  done"


desc "With Whatsapp"
export TOKEN=$(cat config/whatsapp.jwt)
run "cat config/whatsapp.jwt | jwt"
run "for i in {1..3}; do curl -I https://ceposta-gloo-demo.solo.io/httpbin -H \"x-token: \$TOKEN\";  done"

desc "With Whatsapp and priority"
export TOKEN=$(cat config/whatsapp-num-411.jwt)
run "cat config/whatsapp-num-411.jwt | jwt"
run "for i in {1..5}; do curl -I https://ceposta-gloo-demo.solo.io/httpbin -H \"x-token: \$TOKEN\";  done"

desc "Anything else"
export TOKEN=$(cat config/whatsapp-sms.jwt)
run "cat config/whatsapp-sms.jwt | jwt"
run "for i in {1..3}; do curl -I https://ceposta-gloo-demo.solo.io/httpbin -H \"x-token: \$TOKEN\";  done"
