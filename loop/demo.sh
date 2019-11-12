#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD


killall kubectl
kubectl port-forward -n calc deploy/example-service1 8080:8080  &> /dev/null &
SVC_PID=$!

kubectl port-forward -n loop-system deployment/loop 5678 &> /dev/null &

kubectl delete pods -n squash-debugger --all > /dev/null 2>&1
kubectl delete envoyfilters -n loop-system --all > /dev/null 2>&1
kubectl delete taps -n loop-system --all > /dev/null 2>&1

#code $GOPATH/src/github.com/solo-io/squash/contrib/example/service2-java
#code $GOPATH/src/github.com/solo-io/squash/contrib/example/service1
# remote path: /home/yuval/go/src/github.com/solo-io/squash/contrib/example/service1

open http://localhost:8080

desc "Starting squash demo"
read -s
desc "Go debug and fix it"
read -s
desc "Take a look at behavior... we can patch?"
read -s

kubectl delete po --all -n squash-debugger  &> /dev/null
desc "Let's patch"
run "./patch-service2-ise.sh"


desc "verify correct behavior"
read -s
desc "Let's use loop!"
run "loopctl"

desc "Let's register a loop definition"
run "cat resources/tap.yaml"
run "kubectl apply -f resources/tap.yaml"
run "kubectl apply -f resources/envoyfilter.yaml"
run "kubectl delete pods -n calc --all"

kubectl delete po -l app=pilot -n istio-system > /dev/null 2>&1

# we have to redo this for some reason
kill -9 $SVC_PID > /dev/null 2>&1
read -s
kubectl port-forward -n calc deploy/example-service1 8080:8080  > /dev/null &
read -s

desc "Let's check what recordings we have so far before we've generated any errors"
run "loopctl list"

desc "Now go find some errors"
read -s

desc "Let's check again after we've found an error"
run "loopctl list"

desc "Let's attach a debugger to this new code"
code $GOPATH/src/github.com/solo-io/squash/contrib/example/service2-500
#remote path set to /Users/mitch/go/src/github.com/solo-io/squash/contrib/example/service2-500
read -s

desc "Let's replay the traffic"
run "loopctl replay --id 1"
