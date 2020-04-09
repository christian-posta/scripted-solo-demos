#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD

source ./env.sh

desc "Admiral helps make services global by creating service entries for a globally unique name"
desc "Let's make sure we don't have any service entries"
run "kubectl get serviceentry -A"


desc "Let's deploy some services on cluster 1 and observe what Admiral does"
run "kubectl --context $CLUSTER_1 apply -f resources/sample.yaml"
run "kubectl --context $CLUSTER_1 get po -n sample -w"

backtotop
desc "Let's review what service entries were created"
read -s

run "kubectl --context $CLUSTER_1 get serviceentry -n admiral-sync"

desc "Let's take a closer look at the greetings.global service"
run "kubectl --context $CLUSTER_1 get serviceentry -n admiral-sync default.greeting.global-se -o yaml"

backtotop
desc "Let's try calling the global name from webapp service"
read -s

WEBAPP_POD=$(kubectl --context $CLUSTER_1 get pod -l "app=webapp" --namespace=sample -o jsonpath='{.items[0].metadata.name}')
run "kubectl --context $CLUSTER_1 exec --namespace=sample -it $WEBAPP_POD -c webapp -- curl -v http://default.greeting.global"



backtotop
desc "Everything looks good"
desc "Let's deploy the greeting workload to the second cluster on a different namespace"
read -s

run "kubectl --context $CLUSTER_2 apply -f resources/greeting-otherns.yaml"
run "kubectl --context $CLUSTER_2 get po -n otherns -w"

backtotop
desc "Let's take a look at the global greetings SE again"
read -s

run "kubectl --context $CLUSTER_1 get serviceentry -n admiral-sync default.greeting.global-se -o yaml"


desc "let's see what SEs were created on the second cluster"
run "kubectl --context $CLUSTER_2 get serviceentry -n admiral-sync"
run "kubectl --context $CLUSTER_2 get serviceentry -n admiral-sync default.greeting.global-se -o yaml"





backtotop
desc "Let's try calling greeting 3x again from webapp"
read -s

run "kubectl --context $CLUSTER_1 exec --namespace=sample -it $WEBAPP_POD -c webapp -- curl -v http://default.greeting.global"
run "kubectl --context $CLUSTER_1 exec --namespace=sample -it $WEBAPP_POD -c webapp -- curl -v http://default.greeting.global"
run "kubectl --context $CLUSTER_1 exec --namespace=sample -it $WEBAPP_POD -c webapp -- curl -v http://default.greeting.global"
run "kubectl --context $CLUSTER_1 exec --namespace=sample -it $WEBAPP_POD -c webapp -- curl -v http://default.greeting.global"

backtotop
desc "Let's scale down the local greeting service and make sure we connect over to the second cluster"
read -s

run "kubectl --context $CLUSTER_1 -n sample scale deploy/greeting --replicas=0"

desc "Now let's try the traffic again"
run "kubectl --context $CLUSTER_1 exec --namespace=sample -it $WEBAPP_POD -c webapp -- curl -v http://default.greeting.global"
run "kubectl --context $CLUSTER_1 exec --namespace=sample -it $WEBAPP_POD -c webapp -- curl -v http://default.greeting.global"
run "kubectl --context $CLUSTER_1 exec --namespace=sample -it $WEBAPP_POD -c webapp -- curl -v http://default.greeting.global"


exit


desc "Let's create a dependency mapping"
run "kubectl apply -f resources/sample_dep.yaml"


