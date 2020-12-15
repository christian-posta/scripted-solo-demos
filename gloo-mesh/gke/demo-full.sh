#!/bin/bash
. $(dirname ${BASH_SOURCE})/../../util.sh

SOURCE_DIR=$PWD
source env.sh

echo "Make sure management plane cluster is up and GM installed"
echo "UI should be on http://localhost:8090"
read -s

kubectl config use-context $MGMT_CONTEXT

backtotop
desc "Let's register our two clusters"
read -s

run "meshctl cluster register --cluster-name $CLUSTER_1_NAME --remote-context $CLUSTER_1 --mgmt-context $MGMT_CONTEXT"

run "meshctl cluster register --cluster-name $CLUSTER_2_NAME --remote-context $CLUSTER_2 --mgmt-context $MGMT_CONTEXT"

desc "Now we should have discovered the meshes"
run "kubectl get kubernetesclusters -n gloo-mesh"
run "kubectl get meshes -n gloo-mesh"
run "kubectl get workloads -n gloo-mesh"

desc "Now let's look at federating the clusters"

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
desc "let's check the certs now in the workloads"
read -s

desc "Cert chain we see on cluster 1"
REVIEWS_POD=$(kubectl get po -n default -l app=reviews --context $CLUSTER_1 | grep -i running | head -n 1 | awk '{ print $1 }')
run "kubectl --context $CLUSTER_1 exec -it $REVIEWS_POD -c istio-proxy -- openssl s_client -showcerts -connect ratings.default:9080"

desc "Cert chain we see on cluster 2"
REVIEWS_POD=$(kubectl get po -n default -l app=reviews --context $CLUSTER_2 | grep -i running | head -n 1 | awk '{ print $1 }')
run "kubectl --context $CLUSTER_2 exec -it $REVIEWS_POD -c istio-proxy -- openssl s_client -showcerts -connect ratings.default:9080"

desc "We now have a common root of trust, with intermediates signed and no keys exchanging over the network"


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
tmux send-keys -t 1 "kubectl --context $CLUSTER_1 -n istio-system port-forward svc/istio-ingressgateway  9080:80" C-m

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
desc "Now that we've got our mesh federated, let's take a look at the networking"
read -s
desc "Show some of the underlying Istio objects automatically created"
run "kubectl get serviceentry -A --context $CLUSTER_1"
run "kubectl get serviceentry -A --context $CLUSTER_2"
run "kubectl get serviceentry reviews.default.svc.cluster-2.global -o yaml -n istio-system  --context $CLUSTER_1"

backtotop
desc "Now let's route reviews traffic to balance between cluster 1 and 2"
read -s

run "cat resources/reviews-tp-c1-c2.yaml"

desc "Let's apply it and see what resources it creates"
run "kubectl apply -f resources/reviews-tp-c1-c2.yaml"
run "kubectl get virtualservice -A --context $CLUSTER_1"
run "kubectl get virtualservice -A -o yaml --context $CLUSTER_1"

desc "Damn! We didn't enable traffic for cluster 2 for reviews!"
run "kubectl apply -f resources/enable-reviews-cluster-2.yaml"

#############################################
# Traffic Failover
#############################################
desc "In the previous demos, we federated the meshes and enabled access"
desc "In this demo, we'll explore how to declare failover behavior"
read -s

# Delete traffic policy
desc "First let's clean up from the previous demo"
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
desc "To test it, let's make the reviews service (v1, v2) unhealthy on cluster-1"
read -s

# kubectl --context $CLUSTER_1 patch deploy reviews-v1 --patch '{"spec": {"template": {"spec": {"containers": [{"name": "reviews","command": ["sleep", "20h"]}]}}}}'
run "kubectl --context $CLUSTER_1 patch deploy reviews-v1 --patch '{\"spec\": {\"template\": {\"spec\": {\"containers\": [{\"name\": \"reviews\",\"command\": [\"sleep\", \"20h\"]}]}}}}'"

# run kubectl --context $CLUSTER_1 patch deploy reviews-v2 --patch '{"spec": {"template": {"spec": {"containers": [{"name": "reviews","command": ["sleep", "20h"]}]}}}}'
run "kubectl --context $CLUSTER_1 patch deploy reviews-v2 --patch '{\"spec\": {\"template\": {\"spec\": {\"containers\": [{\"name\": \"reviews\",\"command\": [\"sleep\", \"20h\"]}]}}}}'"


# watch the logs in other cluster
run "kubectl --context $CLUSTER_2 logs -l app=reviews -c istio-proxy -f"

# As you refresh the page, you should see traffic failover to the other cluster via logging