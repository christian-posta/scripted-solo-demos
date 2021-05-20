. ./env.sh

helm uninstall gloo-mesh-enterprise -n gloo-mesh --kube-context $MGMT_CONTEXT


kubectl --context $MGMT_CONTEXT delete crd $(kubectl --context $MGMT_CONTEXT get crd | grep "mesh.gloo.solo.io")

kubectl delete ns gloo-mesh
