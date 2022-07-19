

export CILIUM_HELM_VERSION=1.11.2
export CLUSTER1=cluster1
export CLUSTER2=cluster2

#Call the service
kubectl exec -ti deployment/x-wing -- curl rebel-base 



kubectl --context cluster1 exec -ti pod/x-wing-87969bbc5-9chts -- curl rebel-base 


cni-ea4d01b1-6567-0ea6-0e0f-880d8a704260