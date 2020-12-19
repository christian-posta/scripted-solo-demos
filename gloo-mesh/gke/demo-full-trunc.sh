#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

SOURCE_DIR=$PWD

source env.sh

echo "Make sure management plane cluster is up and GM installed"
echo "UI should be on http://localhost:8090"
read -s

kubectl config use-context $MGMT_CONTEXT

#############################################
# Access Policy
#############################################
backtotop
desc "Using this federated mesh, we can do things like control the access policies "
read -s

desc "Let's port-forward the bookinfo demo so we can see its behavior"
desc "Make sure to go to http://localhost:9080/productpage"
tmux split-window -v -d -c $SOURCE_DIR
tmux select-pane -t 0
tmux send-keys -t 1 "source env.sh" C-m
tmux send-keys -t 1 "kubectl --context $CLUSTER_1 -n istio-system port-forward svc/istio-ingressgateway 9080:80" C-m

desc "Go to the browser make sure it works: http://localhost:9080/productpage"
read -s

backtotop
desc "Let's enable access policy on the virtualmesh"
read -s

run "cat resources/virtual-mesh-access.yaml"
run "kubectl apply -f resources/virtual-mesh-access.yaml"

desc "We should see we cannot access bookinfo correctly"
read -s

backtotop
desc "Now let's enable traffic"
read -s

desc "Enable traffic from the ing gateway to product page"
run "cat resources/enable-productpage-acp.yaml"
run "kubectl apply -f resources/enable-productpage-acp.yaml"

desc "Enable traffic from product page to reviews/details"
run "cat resources/enable-productpage-reviews.yaml"
run "kubectl apply -f resources/enable-productpage-reviews.yaml"

desc "Enable traffic from reviews page to ratings"
run "cat resources/enable-reviews-acp.yaml"
run "kubectl apply -f resources/enable-reviews-acp.yaml"


#############################################
# Traffic Routing
#############################################
backtotop
desc "Now let's explicitly control traffic between cluster 1 and cluster 2"
read -s

run "cat resources/reviews-tp-c1-c2.yaml"

desc "Let's apply it and see what resources it creates"
run "kubectl apply -f resources/reviews-tp-c1-c2.yaml"

desc "Review the routing in the UI"
read -s

desc "Damn! We didn't enable traffic for cluster 2 for reviews!"
run "kubectl apply -f resources/enable-reviews-cluster-2.yaml"
read -s

#############################################
# Traffic Failover
#############################################
desc "Now let's declare failover behavior between clusters"
read -s

# Delete traffic policy
desc "Let's demonstrate failover between clusters"
run "kubectl delete TrafficPolicy reviews-tp -n gloo-mesh"

desc "Next we need to add passive health checking to determine health and when to failover"
run "cat resources/reviews-outlier-tp.yaml"
run "kubectl apply -f resources/reviews-outlier-tp.yaml"


backtotop
desc "Now that we've defined health checking, let's see how to specify failover:"
read -s

run "cat resources/reviews-failover.yaml"
run "kubectl apply -f resources/reviews-failover.yaml"



backtotop
desc "To test it, let's make the reviews service (v1, v2) unhealthy on eks-d cluster"
read -s

run "kubectl --context $CLUSTER_1 patch deploy reviews-v1 --patch '{\"spec\": {\"template\": {\"spec\": {\"containers\": [{\"name\": \"reviews\",\"command\": [\"sleep\", \"20h\"]}]}}}}'"
run "kubectl --context $CLUSTER_1 patch deploy reviews-v2 --patch '{\"spec\": {\"template\": {\"spec\": {\"containers\": [{\"name\": \"reviews\",\"command\": [\"sleep\", \"20h\"]}]}}}}'"


# watch the logs in other cluster
run "kubectl --context $CLUSTER_2 logs -l app=reviews -c istio-proxy -f"

desc "You can also see all of this in the UI!"
read -s