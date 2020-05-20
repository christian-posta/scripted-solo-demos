export CLUSTER_1=$(kubectl config get-contexts | grep kind-management-plane | awk '{ print $2 }')
export CLUSTER_2=$(kubectl config get-contexts | grep kind-target-cluster | awk '{ print $2 }')
