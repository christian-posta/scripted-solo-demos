#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD

source ./env.sh

desc "Make sure to start from a reset demo state"
read -s

desc "Let's see the dependency feature and create SEs depending on dep graph"
desc "Let's make sure we don't have any service entries"
run "kubectl --context $CLUSTER_1 get serviceentry -A"
run "kubectl --context $CLUSTER_2 get serviceentry -A"


desc "Let's deploy some services on cluster 1 and cluster 2"
run "kubectl --context $CLUSTER_1 apply -f resources/sample.yaml"
run "kubectl --context $CLUSTER_1 get po -n sample -w"

run "kubectl --context $CLUSTER_2 create ns otherns"
run "kubectl --context $CLUSTER_2 apply -f resources/webapp.yaml -n otherns"
run "kubectl --context $CLUSTER_2 get po -n otherns -w"

run "kubectl --context $CLUSTER_1 get serviceentry -n admiral-sync"
run "kubectl --context $CLUSTER_2 get serviceentry -n admiral-sync"

desc "But webapp depends on greeting! We need to be able to call greeting in cluster2 (ie a SE)"

WEBAPP_POD=$(kubectl --context $CLUSTER_2 get pod -l "app=webapp" --namespace=otherns -o jsonpath='{.items[0].metadata.name}')
run "kubectl --context $CLUSTER_2 exec -n otherns -it $WEBAPP_POD -c webapp -- curl -v http://default.greeting.global"

backtotop
desc "Let's create a dependency mapping"
read -s

run "cat resources/sample_dep.yaml"
run "kubectl apply -f resources/sample_dep.yaml"

desc "We should now see a service entry on cluster 2 for greeting"
run "kubectl --context $CLUSTER_2 get serviceentry -n admiral-sync"

desc "Now let's call it"
run "kubectl --context $CLUSTER_2 exec -n otherns -it $WEBAPP_POD -c webapp -- curl -v http://default.greeting.global"

