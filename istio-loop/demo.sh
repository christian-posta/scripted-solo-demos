#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD
LOOPCTL=$(relative ./loopctl)

kubectl port-forward -n loop-system deployment/loop 5678 &> /dev/null &

#code $GOPATH/src/github.com/solo-io/squash/contrib/example/service2-java
#code $GOPATH/src/github.com/solo-io/squash/contrib/example/service1
# remote path: /home/yuval/go/src/github.com/solo-io/squash/contrib/example/service1

INGRESS_IP=$(kubectl get svc -n istio-system | grep ingressgateway | head -n 1 | awk '{ print $4 }'
)
#open http://$INGRESS_IP

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
run "$LOOPCTL"

desc "Let's register a loop definition"
run "cat resources/tap.yaml"
run "kubectl apply -f resources/tap.yaml"
run "kubectl apply -f resources/envoyfilter.yaml"
#run "kubectl delete pods -n calc --all"

kubectl delete po -l app=pilot -n istio-system > /dev/null 2>&1

desc "Let's check what recordings we have so far before we've generated any errors"
run "$LOOPCTL list"

desc "Now go find some errors"
read -s

desc "Let's check again after we've found an error"
run "$LOOPCTL list"

desc "Let's attach a debugger to this new code"
code $GOPATH/src/github.com/solo-io/squash/contrib/example/service2-500
#remote path set to /Users/mitch/go/src/github.com/solo-io/squash/contrib/example/service2-500
read -s

desc "Let's replay the traffic"
run "$LOOPCTL replay --id 1"
