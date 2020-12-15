#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

SOURCE_DIR=$PWD

source env.sh
echo "kubeconfig: $KUBECONFIG"

echo "Make sure management plane cluster is up and GM installed"
echo "UI should be on http://localhost:8090"
read -s

kubectl config use-context $MGMT_CONTEXT

backtotop
desc "Let's register our two clusters"
read -s

# EKS-d running locally needs to be registered with host.docker.internal
run "meshctl cluster register --cluster-name $CLUSTER_1_NAME --remote-context $CLUSTER_1 --mgmt-context $MGMT_CONTEXT"

run "meshctl cluster register --cluster-name $CLUSTER_2_NAME --remote-context $CLUSTER_2 --mgmt-context $MGMT_CONTEXT"

#############################################
# Trust Federation
#############################################

kubectl apply -f resources/peerauth-strict.yaml --context $CLUSTER_1 > /dev/null 2>&1
kubectl apply -f resources/peerauth-strict.yaml --context $CLUSTER_2 > /dev/null 2>&1

backtotop
desc "Right now, the two meshes have different root trusts"
read -s


backtotop
desc "The VirtualMesh CRD allows us to federate  and unify the two meshes"
read -s

run "cat resources/virtual-mesh.yaml"
run "kubectl apply -f resources/virtual-mesh.yaml"

. ./check-virtualmesh.sh

desc "restarting workloads for new certs..."
kubectl delete po --wait=false -n default --all --context $CLUSTER_1 > /dev/null 2>&1
kubectl delete po --wait=false -n default --all --context $CLUSTER_2 > /dev/null 2>&1

kubectl --context $CLUSTER_1 -n istio-system delete pod -l app=istio-ingressgateway > /dev/null 2>&1
kubectl --context $CLUSTER_2 -n istio-system delete pod -l app=istio-ingressgateway > /dev/null 2>&1

run "kubectl get po -n default -w --context $CLUSTER_1"

backtotop
desc "Using this federated mesh, we can do things like control the access and traffic policies "
read -s

desc "Let's port-forward the bookinfo demo so we can see its behavior"
desc "Make sure to go to http://localhost:9080/productpage"
tmux split-window -v -d -c $SOURCE_DIR
tmux select-pane -t 0
tmux send-keys -t 1 "source env.sh" C-m
tmux send-keys -t 1 "kubectl --context $CLUSTER_1 -n istio-system port-forward svc/istio-ingressgateway  9080:80" C-m

desc "Go to the browser make sure it works: http://localhost:9080/productpage"
read -s


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