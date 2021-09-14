source ../env.sh


kubectl --context $CLUSTER_1 create ns gloo-mesh-gateway 
kubectl --context $CLUSTER_2 create ns gloo-mesh-gateway 

istioctl --context $CLUSTER_1 install -y -f ingress-gateways-1.yaml 
istioctl --context $CLUSTER_2 install -y -f ingress-gateways-2.yaml 

# have to hack this
#kubectl --context gloo-mesh-1 set env deploy/gloo-mesh-gateway -n gloo-mesh-gateway ISTIO_META_CLUSTER_ID=cluster-1

#kubectl --context gloo-mesh-2 set env deploy/gloo-mesh-gateway -n gloo-mesh-gateway ISTIO_META_CLUSTER_ID=cluster-2


# Install new CRDs

kubectl apply --context $MGMT_CONTEXT -f  https://raw.githubusercontent.com/solo-io/gloo-mesh/edge-2.0/install/helm/gloo-mesh-crds/crds/discovery.mesh.gloo.solo.io_v1_crds.yaml
kubectl apply --context $MGMT_CONTEXT -f  https://raw.githubusercontent.com/solo-io/gloo-mesh/edge-2.0/install/helm/gloo-mesh-crds/crds/multicluster.solo.io_v1alpha1_crds.yaml
kubectl apply --context $MGMT_CONTEXT -f  https://raw.githubusercontent.com/solo-io/gloo-mesh/edge-2.0/install/helm/gloo-mesh-crds/crds/networking.enterprise.mesh.gloo.solo.io_v1beta1_crds.yaml
kubectl apply --context $MGMT_CONTEXT -f  https://raw.githubusercontent.com/solo-io/gloo-mesh/edge-2.0/install/helm/gloo-mesh-crds/crds/networking.mesh.gloo.solo.io_v1_crds.yaml
kubectl apply --context $MGMT_CONTEXT -f  https://raw.githubusercontent.com/solo-io/gloo-mesh/edge-2.0/install/helm/gloo-mesh-crds/crds/observability.enterprise.mesh.gloo.solo.io_v1_crds.yaml
kubectl apply --context $MGMT_CONTEXT -f  https://raw.githubusercontent.com/solo-io/gloo-mesh/edge-2.0/install/helm/gloo-mesh-crds/crds/rbac.enterprise.mesh.gloo.solo.io_v1_crds.yaml
kubectl apply --context $MGMT_CONTEXT -f  https://raw.githubusercontent.com/solo-io/gloo-mesh/edge-2.0/install/helm/gloo-mesh-crds/crds/settings.mesh.gloo.solo.io_v1_crds.yaml


## manually edit
kubectl edit clusterrole enterprise-networking --context $MGMT_CONTEXT

## so it looks like this:
apiGroups:
- networking.enterprise.mesh.gloo.solo.io
resources:
- wasmdeployments
- virtualdestinations
- servicedependencies
- virtualgateways
- virtualhosts
- routetables

and further down:

apiGroups:
- networking.enterprise.mesh.gloo.solo.io
resources:
- wasmdeployments/status
- virtualdestinations/status
- servicedependencies/status
- virtualgateways/status
- virtualhosts/status
- routetables/status


## Now we need to edit the enterprise networking agent to patch the image:

kubectl --context $MGMT_CONTEXT edit --namespace gloo-mesh deploy/enterprise-networking

update the image to:
gcr.io/solo-public/enterprise-networking:1.1.0-gateway0-1

kubectl edit --context $CLUSTER_1 --namespace gloo-mesh deploy/enterprise-agent
kubectl edit --context $CLUSTER_2 --namespace gloo-mesh deploy/enterprise-agent
gcr.io/solo-public/enterprise-agent:1.1.0-gateway0-1

kubectl apply --context $CLUSTER_1 -f https://raw.githubusercontent.com/solo-io/gloo-mesh/edge-2.0/install/helm/gloo-mesh-crds/crds/discovery.mesh.gloo.solo.io_v1_crds.yaml 

kubectl apply --context $CLUSTER_2 -f https://raw.githubusercontent.com/solo-io/gloo-mesh/edge-2.0/install/helm/gloo-mesh-crds/crds/discovery.mesh.gloo.solo.io_v1_crds.yaml 