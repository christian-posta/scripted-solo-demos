. ./env.sh

echo "Uninstall Gloo Mesh"
helm uninstall gloo-mesh-enterprise -n gloo-mesh --kube-context $MGMT_CONTEXT

echo "Uninstall Federation"
helm uninstall gloo-fed -n gloo-fed --kube-context $MGMT_CONTEXT

echo "Uninstall Gloo edge"
helm uninstall gloo-edge -n gloo-system --kube-context $MGMT_CONTEXT

echo "Delete all solo CRDs"
kubectl --context $MGMT_CONTEXT delete crd $(kubectl --context $MGMT_CONTEXT get crd | grep "solo.io" | awk '{print $1}')


# Delete namespaces
kubectl --context $MGMT_CONTEXT delete ns gloo-fed
kubectl --context $MGMT_CONTEXT delete ns argocd
kubectl --context $MGMT_CONTEXT delete ns gogs
kubectl --context $MGMT_CONTEXT delete ns gloo-system
kubectl --context $MGMT_CONTEXT delete ns gloo-mesh
kubectl --context $MGMT_CONTEXT delete ns demo-config