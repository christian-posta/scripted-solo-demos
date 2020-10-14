#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

SOURCE_DIR=$PWD
source env.sh
kubectl config use-context $MGMT_CONTEXT

desc "In the previous demos, we federated the meshes and enabled access"
desc "In this demo, we'll explore how to declare failover behavior"
read -s

# Delete traffic policy
desc "First let's clean up from the previous demo"
run "kubectl delete TrafficPolicy reviews-tp -n service-mesh-hub"

desc "Next we need to add passive health checking to determine health and when to failover"
run "cat resources/reviews-outlier-tp.yaml"
run "kubectl apply -f resources/reviews-outlier-tp.yaml"


backtotop
desc "Now that we've defined health checking, let's see how to specify failover:"
read -s

run "cat resources/reviews-failover.yaml"
run "kubectl apply -f resources/reviews-failover.yaml"

backtotop
desc "Now when we call the reviews service, we want it to go to failover"
read -s

run "cat resources/reviews-failover-tp.yaml"
run "kubectl apply -f resources/reviews-failover-tp.yaml"

backtotop
desc "To test it, let's make the reviews service (v1, v2) unhealthy on cluster-1"
read -s

# kubectl --context $CLUSTER_1 patch deploy reviews-v1 --patch '{"spec": {"template": {"spec": {"containers": [{"name": "reviews","command": ["sleep", "20h"]}]}}}}'
run "kubectl --context $CLUSTER_1 patch deploy reviews-v1 --patch '{\"spec\": {\"template\": {\"spec\": {\"containers\": [{\"name\": \"reviews\",\"command\": [\"sleep\", \"20h\"]}]}}}}'"

# run kubectl --context $CLUSTER_1 patch deploy reviews-v2 --patch '{"spec": {"template": {"spec": {"containers": [{"name": "reviews","command": ["sleep", "20h"]}]}}}}'
run "kubectl --context $CLUSTER_1 patch deploy reviews-v2 --patch '{\"spec\": {\"template\": {\"spec\": {\"containers\": [{\"name\": \"reviews\",\"command\": [\"sleep\", \"20h\"]}]}}}}'"


# watch the logs in other cluster
run "kubectl --context $CLUSTER_2 logs -l app=reviews -c istio-proxy -f"

# As you refresh the page, you should see traffic failover to the other cluster via logging


