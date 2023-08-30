
export MGMT=mgmt
export CLUSTER1=cluster1
export CLUSTER2=cluster2

kubectl config use-context ${MGMT}

# delete gitops
kubectl --context ${CLUSTER1} delete ns argocd
kubectl --context ${CLUSTER1} delete ns gogs

# uninstall istio cluster 1
helm --kube-context=${CLUSTER1} uninstall istio-base  -n istio-system
helm --kube-context=${CLUSTER1} uninstall istio-1.11.7 -n istio-system
kubectl --context ${CLUSTER1} delete ns istio-system


helm --kube-context=${CLUSTER1} uninstall istio-ingressgateway -n istio-gateways
helm --kube-context=${CLUSTER1} uninstall istio-eastwestgateway -n istio-gateways

kubectl --context ${CLUSTER1} delete ns istio-gateways


# uninstall istio cluster 2
helm --kube-context=${CLUSTER2} uninstall istio-base  -n istio-system
helm --kube-context=${CLUSTER2} uninstall istio-1.11.7 -n istio-system
kubectl --context ${CLUSTER2} delete ns istio-system


helm --kube-context=${CLUSTER2} uninstall istio-ingressgateway -n istio-gateways
helm --kube-context=${CLUSTER2} uninstall istio-eastwestgateway -n istio-gateways

kubectl --context ${CLUSTER2} delete ns istio-gateways



kubectl --context ${CLUSTER1} delete ns bookinfo-frontends
kubectl --context ${CLUSTER1} delete ns bookinfo-backends

kubectl --context ${CLUSTER2} delete ns bookinfo-frontends
kubectl --context ${CLUSTER2} delete ns bookinfo-backends

kubectl --context ${CLUSTER1} delete ns httpbin
kubectl --context ${CLUSTER1} delete ns sleep
kubectl --context ${CLUSTER2} delete ns sleep




helm repo add gloo-mesh-enterprise https://storage.googleapis.com/gloo-mesh-enterprise/gloo-mesh-enterprise 
helm repo update

helm uninstall gloo-mesh-enterprise \
--namespace gloo-mesh --kube-context ${MGMT} 

kubectl --context ${MGMT} delete ns gloo-mesh 



helm uninstall gloo-mesh-agent \
  --namespace gloo-mesh \
  --kube-context=${CLUSTER1} 

kubectl --context ${CLUSTER1} delete ns gloo-mesh


helm uninstall gloo-mesh-agent \
  --namespace gloo-mesh \
  --kube-context=${CLUSTER2} 

kubectl --context ${CLUSTER2} delete ns gloo-mesh



helm uninstall gloo-mesh-agent-addons  \
  --namespace gloo-mesh-addons \
  --kube-context=${CLUSTER1}

helm uninstall gloo-mesh-agent-addons  \
  --namespace gloo-mesh-addons \
  --kube-context=${CLUSTER2}  

kubectl --context ${CLUSTER1} delete namespace gloo-mesh-addons

kubectl --context ${CLUSTER2} delete namespace gloo-mesh-addons


