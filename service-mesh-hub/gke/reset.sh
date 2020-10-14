source env.sh
rm -fr ./temp/*.*

kind delete cluster --name smh-management


kubectl delete -f resources/peerauth-strict.yaml --context $CLUSTER_1
kubectl delete -f resources/peerauth-strict.yaml --context $CLUSTER_2

#############################################
# traffic policy
#############################################
kubectl delete trafficpolicy -n service-mesh-hub --all --context $CLUSTER_1
kubectl delete virtualservices.networking.istio.io  reviews -n default --context $CLUSTER_1
kubectl delete gateway smh-vm-virtual-mesh-gateway -n istio-system
kubectl delete envoyfilter smh-virtual-mesh-filter -n istio-system 

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
kubectl --context $CLUSTER_1 delete clusterrole $(kubectl --context $CLUSTER_1 get clusterrole | grep csr-agent)
kubectl --context $CLUSTER_1 delete clusterrolebinding $(kubectl --context $CLUSTER_1 get clusterrolebinding |  grep csr-agent)



kubectl --context $CLUSTER_1 delete clusterrole $(kubectl --context $CLUSTER_1 get clusterrole | grep mesh-discovery)
kubectl --context $CLUSTER_1 delete clusterrolebinding $(kubectl --context $CLUSTER_1 get clusterrolebinding |  grep mesh-discovery)


kubectl --context $CLUSTER_1 delete clusterrole $(kubectl --context $CLUSTER_1 get clusterrole | grep mesh-networking-clusterrole)
kubectl --context $CLUSTER_1 delete clusterrolebinding $(kubectl --context $CLUSTER_1 get clusterrolebinding |  grep mesh-networking-clusterrole)




kubectl --context $CLUSTER_2 delete clusterrole $(kubectl --context $CLUSTER_2 get clusterrole | grep csr-agent)
kubectl --context $CLUSTER_2 delete clusterrolebinding $(kubectl --context $CLUSTER_2 get clusterrolebinding | grep csr-agent)

kubectl --context $CLUSTER_2 delete clusterrole $(kubectl --context $CLUSTER_2 get clusterrole | grep mesh-discovery)
kubectl --context $CLUSTER_2 delete clusterrolebinding $(kubectl --context $CLUSTER_2 get clusterrolebinding |  grep mesh-discovery)

kubectl --context $CLUSTER_2 delete clusterrole $(kubectl --context $CLUSTER_2 get clusterrole | grep mesh-networking)
kubectl --context $CLUSTER_2 delete clusterrolebinding $(kubectl --context $CLUSTER_2 get clusterrolebinding |  grep mesh-networking)


kubectl delete virtualmesh virtual-mesh -n service-mesh-hub --context $CLUSTER_1

kubectl delete secret -n istio-system cacerts --context $CLUSTER_1
kubectl delete secret -n istio-system istio-ca-secret --context $CLUSTER_1

kubectl delete secret -n istio-system cacerts --context $CLUSTER_2
kubectl delete secret -n istio-system istio-ca-secret --context $CLUSTER_2

kubectl delete pod -n istio-system -l app=istiod --context $CLUSTER_1
kubectl delete po --wait=false -n default --all --context $CLUSTER_1 > /dev/null 2>&1

kubectl delete pod -n istio-system -l app=istiod --context $CLUSTER_2
kubectl delete po --wait=false -n default --all --context $CLUSTER_2 > /dev/null 2>&1

kubectl delete secret virtual-mesh-ca-certs --context $CLUSTER_1

#############################################
# Discovery
#############################################

# delete all kubernetes clusters
kubectl delete meshes -A --all --context $CLUSTER_1
# delete all meshes
kubectl delete kubernetesclusters -A --all --context $CLUSTER_1

meshctl uninstall


kubectl delete ns service-mesh-hub --context $CLUSTER_1
kubectl delete ns service-mesh-hub --context $CLUSTER_2