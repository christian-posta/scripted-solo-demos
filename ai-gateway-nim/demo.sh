. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD

source env.sh
source env-gateway.sh

desc "Scaling traffic with NVIDIA NIM"
read -s

desc "We have the Gloo AI Gateway deployed in cluster 1 and 2"
run "kubectl --context $CLUSTER1 -n gloo-system get gateway"
run "kubectl --context $CLUSTER2 -n gloo-system get gateway"

desc "We have NVIDIA NIM deployed in cluster 1 and 2"
run "kubectl --context $CLUSTER1 -n nim get po"
run "kubectl --context $CLUSTER2 -n nim get po"

desc "We can call an OpenAI API and route traffic to OpenAI"
run "kubectl --context $CLUSTER1 -n gloo-system get httproute openai -o yaml"

desc "Let's make a call to the Open AI API on Cluster1"
run "./call-gateway1.sh"

desc "All traffic sent to this endpoint will be secured and go to OpenAI"
read -s


backtotop
desc "Let's shift traffic to an optimized, trained model represenrted by NVIDIA NIM"
read -s

run "cat resources/routing/cluster1/openai-5050.yaml"
run "kubectl --context $CLUSTER1 apply -f resources/routing/cluster1/openai-5050.yaml"

desc "Go to a different window and make some calls"
read -s


#backtotop
#desc "Let's make sure that traffic within the cluster is secured with mTLS"
#read -s


run "cat resources/routing/cluster1/openai-0100.yaml"
run "kubectl --context $CLUSTER1 apply -f resources/routing/cluster1/openai-0100.yaml"

desc "Now all calls should go to the local NVIDIA NIM"
read -s

backtotop
desc "Now let's see what happens if the local NIM fails."
read -s

desc "First we need to deploy a Gloo AI Gateway Upstream that fails to the second cluster"
run "./deploy-failover.sh"
run "kubectl --context $CLUSTER1 get upstream nim-llama3-1-8b -n gloo-system -o yaml"

desc "Now let's scale down the NIM in cluster 1"
run "kubectl --context $CLUSTER1 -n nim scale deploy/my-nim --replicas=0"

desc "Now if we call the AI Gateway on cluster 1 it should automatically fail over to cluster 2"
run "./call-gateway1.sh"