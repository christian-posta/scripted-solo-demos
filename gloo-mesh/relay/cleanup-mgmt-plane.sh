. ./env.sh

helm uninstall gloo-mesh-enterprise -n gloo-mesh --kube-context $MGMT_CONTEXT


kubectl --context $MGMT_CONTEXT delete crd $(kubectl --context $MGMT_CONTEXT get crd | grep "mesh.gloo.solo.io")

kubectl --context $MGMT_CONTEXT delete ns gloo-mesh


echo "Uninstall Gloo edge"
helm uninstall gloo-edge -n gloo-system --kube-context $1
kubectl --context $1 delete ns gloo-system

echo "Uninstall Federation"
helm uninstall gloo-fed -n gloo-system --kube-context $1

kubectl --context $MGMT_CONTEXT delete ns argocd
kubectl --context $MGMT_CONTEXT delete ns gogs