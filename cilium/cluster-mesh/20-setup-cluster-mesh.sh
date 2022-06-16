

export CILIUM_HELM_VERSION=1.11.2
export CLUSTER1=cluster1
export CLUSTER2=cluster2

cilium clustermesh enable --context $CLUSTER1 --service-type LoadBalancer 
cilium clustermesh enable --context $CLUSTER2 --service-type LoadBalancer



# NOTE, seems like the helm chart doesn't work very well
# and may not set the ID and name for the cluster1 
# might have to edit directly in the configmap
# k edit cm -n kube-system cilium-config -o yaml
cilium clustermesh status --context $CLUSTER1 --wait
cilium clustermesh status --context $CLUSTER2 --wait