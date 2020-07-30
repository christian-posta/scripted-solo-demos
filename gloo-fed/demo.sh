#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD
source ./env.sh  



#############################################
# Discovery
#############################################
killall kubectl &> /dev/null

kubectl --context $LOCAL_CLUSTER_CONTEXT port-forward svc/gateway-proxy -n gloo-system 8080:80 &> /dev/null &
kubectl --context $REMOTE_CLUSTER_CONTEXT port-forward svc/gateway-proxy -n gloo-system 8081:80 &> /dev/null &

CLUSTER_1="$LOCAL_CLUSTER_CONTEXT"
CLUSTER_2="$REMOTE_CLUSTER_CONTEXT"
kubectl config use-context $CLUSTER_1 &> /dev/null

desc "Welcome to Gloo Federation demo!"
desc "Let's get started"
read -s

desc "We have installed Gloo onto two clusters:"
run "kubectl get po -n gloo-system --context $CLUSTER_1"
run "kubectl get po -n gloo-system --context $CLUSTER_2"

desc "We also have echo service on both cluster"
run "kubectl get po -n default --context $CLUSTER_1 "
run "kubectl get po -n default --context $CLUSTER_2"


backtotop
desc "Let's install the GlooFed management plane onto cluster 1"
read -s
source ~/bin/gloo-license-key-env
run "glooctl install federation --license-key $GLOO_LICENSE"
run "kubectl -n gloo-fed rollout status deployment gloo-fed --timeout=1m"


backtotop
desc "Let's register our two clusters"
read -s

run "glooctl cluster register --remote-context $CLUSTER_1 --cluster-name kind-local --local-cluster-domain-override host.docker.internal --federation-namespace gloo-fed"
run "glooctl cluster register --remote-context $CLUSTER_2 --cluster-name kind-remote --local-cluster-domain-override host.docker.internal --federation-namespace gloo-fed"

backtotop
desc "Let's see how to manage configuration for the clusters"
read -s

desc "Lets enable routing on the gloo gateways with a federated config"
run "cat ./resources/federated-default-vs.yaml"
run "kubectl apply -f ./resources/federated-default-vs.yaml"
run "kubectl get  FederatedVirtualService -A -o yaml"
run "glooctl get vs"

desc "If we call the gateway on cluster 1 to get the echo service, it should work"
run "curl localhost:8080"

desc "If we call the gateway on cluster 1 to get the echo service, it should work"
run "curl localhost:8081"

backtotop
desc "Let's see how easy it is to set up failover between the two gateways"
read -s


desc "If we mark this service as unhealthy, we should see an error"
run "kubectl --context $CLUSTER_1 scale deploy/echo-v1 --replicas=0"
run "curl -v localhost:8080"


backtotop
desc "What we want is for the traffic to failover between gateways and clusters"
read -s

desc "We specify failover semantics with the FailoverScheme CR"
run "cat resources/failover-scheme.yaml"

desc "Let's apply this"
run "kubectl apply -f resources/failover-scheme.yaml"
run "kubectl get failoverscheme -n gloo-fed echo-failover -o yaml"


desc "Let's see under the covers what this did for Gloo's virtual service and upstream"
run "kubectl -n gloo-system get virtualservice federated-default-vs  -o yaml"
run "kubectl -n gloo-system get upstream default-echo-10000 -o yaml"

desc "Let's put our echo service back"
run "kubectl --context $CLUSTER_1 scale deploy/echo-v1 --replicas=1"

desc "Now if we call our service it should work"
run "curl localhost:8080"

desc "If we fail our service"
run "kubectl --context $CLUSTER_1 scale deploy/echo-v1 --replicas=0"

desc "We can still call our service because of failover"
run "curl localhost:8080"

killall kubectl