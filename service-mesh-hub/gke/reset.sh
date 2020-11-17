source env.sh
rm -fr ./temp/*.*


kubectl delete -f resources/peerauth-strict.yaml --context $CLUSTER_1
kubectl delete -f resources/peerauth-strict.yaml --context $CLUSTER_2

kubectl --context $CLUSTER_1 patch deployment reviews-v1  --type json   -p '[{"op": "remove", "path": "/spec/template/spec/containers/0/command"}]'
kubectl --context $CLUSTER_1 patch deployment reviews-v2  --type json   -p '[{"op": "remove", "path": "/spec/template/spec/containers/0/command"}]'



#############################################
# traffic policy
#############################################
kubectl delete virtualservices.networking.istio.io  reviews -n default --context $CLUSTER_1


#############################################
# Access Control
#############################################
kubectl delete authorizationpolicies global-access-control  -n istio-system --context $CLUSTER_1
kubectl delete authorizationpolicies global-access-control  -n istio-system --context $CLUSTER_2

kubectl delete authorizationpolicies -n default --all --context $CLUSTER_1
kubectl delete authorizationpolicies -n default --all --context $CLUSTER_2

#############################################
# Trust Federation
#############################################


kubectl delete virtualmesh virtual-mesh -n gloo-mesh --context $MGMT_CONTEXT

kubectl delete secret -n istio-system cacerts --context $CLUSTER_1
kubectl delete secret -n istio-system istio-ca-secret --context $CLUSTER_1

kubectl delete secret -n istio-system cacerts --context $CLUSTER_2
kubectl delete secret -n istio-system istio-ca-secret --context $CLUSTER_2

kubectl delete pod -n istio-system -l app=istiod --context $CLUSTER_1
kubectl delete po --wait=false -n default --all --context $CLUSTER_1 > /dev/null 2>&1

kubectl delete pod -n istio-system -l app=istiod --context $CLUSTER_2
kubectl delete po --wait=false -n default --all --context $CLUSTER_2 > /dev/null 2>&1

#############################################
# Discovery
#############################################
kubectl delete secret -n gloo-mesh cluster-1 --context $MGMT_CONTEXT
kubectl delete secret -n gloo-mesh cluster-2 --context $MGMT_CONTEXT


kubectl delete trafficpolicy -n gloo-mesh --all --context $MGMT_CONTEXT
kubectl delete failoverservices.networking.mesh.gloo.solo.io -A --all --context $MGMT_CONTEXT
kubectl delete accesspolicies -n gloo-mesh --context $MGMT_CONTEXT
kubectl delete meshes.discovery.mesh.gloo.solo.io -A --all --context $MGMT_CONTEXT
kubectl delete kubernetesclusters.multicluster.solo.io -A --all --context $MGMT_CONTEXT
kubectl delete workloads.discovery.mesh.gloo.solo.io -A --all --context $MGMT_CONTEXT
kubectl delete traffictargets.discovery.mesh.gloo.solo.io -A --all --context $MGMT_CONTEXT
kubectl delete wasmdeployments.enterprise.networking.mesh.gloo.solo.io -A --all --context $MGMT_CONTEXT


kubectl delete ns gloo-mesh --context $CLUSTER_1
kubectl delete ns gloo-mesh --context $CLUSTER_2