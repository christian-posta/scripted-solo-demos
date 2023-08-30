#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh
SOURCE_DIR=$PWD


desc "We cannot allow sleep-v2 to talk to helloworld-v1"
desc "But can we get into a scenario where this IP-identity cache"
desc "gets stale or not-coherent?"
read -s


# grab the node where the helloworld-v1 pod runs
NODEV1=$(kubectl get pod -l app=helloworld,version=v1 -o=jsonpath='{.items[0].spec.nodeName}')
API_SERVER=$(kubectl get service -n default kubernetes -o=jsonpath='{.spec.clusterIP}')
API_SERVEREP=$(kubectl get endpoints -n default kubernetes -o jsonpath='{.subsets[0].addresses[0].ip}')

desc "Let's simulate a network issue between the node which runs helloworld-v1 and the kube-api server..."

run "docker exec $NODEV1 iptables -t mangle -I INPUT -p tcp -s $API_SERVER -j DROP"
run "docker exec $NODEV1 iptables -t mangle -I INPUT -p tcp -s $API_SERVEREP -j DROP"

desc "Lets check out iptables rules"
run "docker exec -it $NODEV1 iptables -t mangle -L INPUT"

desc "We are now dropping traffic from the API server to the node with helloworld-v1 running on it"
read -s

backtotop
desc "*** What happens if there is churn in the cluster and an IP assigned to sleep-v1 gets assigned to sleep-v2? ***"
read -s

run "./run-test.sh"
