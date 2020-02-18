#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD
GLOO_PROXY_URL=$($(relative bin/glooctl) proxy url)

killall kubectl
kubectl port-forward -n loop-system deployment/loop 5678 &> /dev/null &
kubectl delete po --all -n squash-debugger  &> /dev/null

desc "We have a very simple calculator REST API"
# curl -X POST  http://34.82.229.206:80/svc2 -d '{"op1": 5, "op2": 2, "isadd": true}'
run "curl -X POST  http://34.82.229.206:80/svc2 -d '{\"op1\": 5, \"op2\": 2, \"isadd\": true}' && echo"


# curl -X POST  http://34.82.229.206:80/svc2 -d '{"op1": 5, "op2": 2, "isadd": false}'
run "curl -X POST  http://34.82.229.206:80/svc2 -d '{\"op1\": 5, \"op2\": 2, \"isadd\": false}' && echo"


desc "Everything seems to work okay, except for some values"

# curl -X POST  http://34.82.229.206:80/svc2 -d '{"op1": 459, "op2": 62, "isadd": true}'
run "curl -X POST  http://34.82.229.206:80/svc2 -d '{\"op1\": 459, \"op2\": 62, \"isadd\": true}' && echo"

desc "We want to debug this, but not in production"
desc "With loop, we can record the request and replay it"
desc "Potentially in a different environment"

desc "Let's use loop!"
run "loopctl"

desc "Let's register a loop definition"
run "cat resources/tap.yaml"
run "kubectl apply -f resources/tap.yaml"

desc "Let's check what recordings we have so far before we've generated any errors"
run "loopctl list"

desc "Let's regenerate that same error"
# curl -X POST  http://34.82.229.206:80/svc2 -d '{"op1": 459, "op2": 62, "isadd": true}'
run "curl -X POST  http://34.82.229.206:80/svc2 -d '{\"op1\": 459, \"op2\": 62, \"isadd\": true}' && echo"

desc "Let's check again after we've found an error"
run "loopctl list"

desc "Let's attach a debugger to this new code"
code $GOPATH/src/github.com/solo-io/squash/contrib/example/service2-500
#remote path set to /Users/mitch/go/src/github.com/solo-io/squash/contrib/example/service2-500
read -s

desc "Let's replay the traffic"
run "loopctl replay --id 1 --destination example-service2.calc"
