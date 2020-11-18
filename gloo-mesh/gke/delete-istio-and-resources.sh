CLUSTER_1=$1

kubectl --context $CLUSTER_1 delete ns service-mesh-hub
kubectl --context $CLUSTER_1 delete istiooperator example-istiooperator -n istio-operator --force --grace-period=0
kubectl --context $CLUSTER_1 delete crd istiooperators.install.istio.io --force --grace-period=0
kubectl --context $CLUSTER_1 delete ns istio-operator
kubectl --context $CLUSTER_1 delete ns istio-system
kubectl --context $CLUSTER_1 delete crd $(kubectl --context $CLUSTER_1 get crd | grep istio)
kubectl --context $CLUSTER_1 delete crd $(kubectl --context $CLUSTER_1 get crd | grep solo)
kubectl --context $CLUSTER_1 delete clusterrole $(kubectl --context $CLUSTER_1 get clusterrole | grep istio)
kubectl --context $CLUSTER_1 delete clusterrole $(kubectl --context $CLUSTER_1 get clusterrole | grep csr-agent)
 
kubectl --context $CLUSTER_1 delete clusterrolebinding $(kubectl --context $CLUSTER_1 get clusterrolebinding |  grep istio )
kubectl --context $CLUSTER_1 delete clusterrolebinding $(kubectl --context $CLUSTER_1 get clusterrolebinding |  grep csr-agent )

kubectl --context $CLUSTER_1 delete clusterrole $(kubectl --context $CLUSTER_1 get clusterrole | grep mesh-)
kubectl --context $CLUSTER_1 delete clusterrolebinding $(kubectl --context $CLUSTER_1 get clusterrolebinding |  grep mesh- )
kubectl delete deploy --all -n default --context $CLUSTER_1
kubectl delete svc details productpage ratings reviews --context $CLUSTER_1

kubectl --context $CLUSTER_1 delete -f ../resources-common/clean-kube-dns.yaml