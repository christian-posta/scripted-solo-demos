
. $(dirname ${BASH_SOURCE})/../../util.sh
source ./env.sh

desc "Let's install the SMH management plane onto cluster 1"
run "meshctl install --context $CLUSTER_1 "
run "meshctl check --context $CLUSTER_1"
run "meshctl cluster register --remote-context $CLUSTER_1 --remote-cluster-name cluster-1"
run "meshctl cluster register --remote-context $CLUSTER_2 --remote-cluster-name cluster-2 "
run "kubectl apply -f resources/virtual-mesh.yaml --context $CLUSTER_1"
run "meshctl check --context $CLUSTER_1"
run "kubectl get virtualmeshcertificatesigningrequests -n service-mesh-hub -o yaml --context $CLUSTER_2"
desc "Bounce the istio pod (and workloads so they pick up the new cert)"
run "kubectl delete pod -n istio-system -l app=istiod --context $CLUSTER_1"
kubectl delete po --wait=false -n default --all --context $CLUSTER_1 > /dev/null 2>&1
run "kubectl delete pod -n istio-system -l app=istiod --context $CLUSTER_2"
kubectl delete po --wait=false -n default --all --context $CLUSTER_2 > /dev/null 2>&1
run "meshctl check --context $CLUSTER_1"