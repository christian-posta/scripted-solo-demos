#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD


desc "Let's see that we can hit the service"
GLOO_PROXY_URL=$(kubectl get svc -n gloo-system | grep proxy | awk '{ print $4 }')

run "curl -v http://$GLOO_PROXY_URL/"

backtotop

desc "Let's require a valid JWT to proceed"
run "cat resources/echoapp-jwt-vs.yaml"

backtotop

desc "let's apply the jwt vs"
run "kubectl apply -f resources/echoapp-jwt-vs.yaml"


backtotop

desc "Now try to hit the service"
run "curl -v http://$GLOO_PROXY_URL/"

desc "We need a valid JWT to access the service"
run "cat resources/jwt/token-iss-soloio.txt"
read -s

backtotop

desc "Let's try call with this token"
VALID_TOKEN=$(cat resources/jwt/token-iss-soloio.jwt)

run "curl -v -H \"Authorization: Bearer $VALID_TOKEN\"  http://$GLOO_PROXY_URL/"

desc "We see we were routed to the primary service"
read -s

backtotop

desc "Let's pull claims from the token and make routing decisions based on that."
run "cat resources/echoapp-jwt-claims-vs.yaml"
run "kubectl apply -f resources/echoapp-jwt-claims-vs.yaml"

desc "Our previous jwt did not have a svc claim"
run "cat resources/jwt/token-iss-soloio.txt"

desc "Let's use one that has the svc claim"
run "cat resources/jwt/token-iss-soloio-pets.txt"

VALID_TOKEN=$(cat resources/jwt/token-iss-soloio-pets.jwt)
run "curl -v -H \"Authorization: Bearer $VALID_TOKEN\"  http://$GLOO_PROXY_URL/"


desc "You can even try over write the routing header, and you cannot"
echo 'curl -v http://35.233.195.6:80 -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaXNzIjoic29sby5pbyIsInN2YyI6InBldHMiLCJhdWQiOlsiZ2xvbyJdLCJhZG1pbiI6dHJ1ZSwiaWF0IjoxNTE2MjM5MDIyfQ.mT7YQWIj99KGZo3yjrH-U4J9M96JVR_3fvbUnLrbPelHOddjK5Oop5c-guppdrSHiH3w5nBtmE6oOIZJ1KNakWn4HG_zYsigjDrhZfh9KuY4RJzf9DrEllSkEhfPyqlcCFuV9jU1CjaGtFN-eJi871oQVwDX0sBMAHcv51bNWTgjJYcCDeetQDQJrFP0WTh2vkXVa9tTP-wKAD_0PhS0V4EmCsX5O6NiJQ03ytEz1LCw09ddaRywXZSCgHOUkTaRmWX0YJYkIOMiLHISslQyLuVwHO0t3odhzP0oWcAHgJw7Au-19WDYkHGW4atGy7trj99Db63_9Nc6Mt5kbPRExw" -H "x-group: foo"'