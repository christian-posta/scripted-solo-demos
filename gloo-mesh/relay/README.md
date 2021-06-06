## Gloo Mesh global routing, multi-cluster, multi-region with Gloo Edge and ArgoCD

Salient notes for this demo:

Global URLs:
http://argocd.mesh.ceposta.solo.io
http://gogs.mesh.ceposta.solo.io
http://dashboard.mesh.ceposta.solo.io

Global service hostnames
http://web-api.mesh.ceposta.solo.io
^^ this is routable from outside the mesh as well as within the mesh with GM VirtualDestination

DNS is set to regional affinity; if you curl http://web-api.mesh.ceposta.solo.io from west coast, you'll be routed to west cluster, if you curl from Europe, you should be routed to east cluster.

Note, the config namespace is `demo-config` in the Gloo Mesh Management plane

cat << EOF | kubectl --context $MGMT_CONTEXT apply -f -

<some policy here>

EOF


## Notes for upgrade:

May need new CRDs:
https://github.com/solo-io/gloo-mesh/blob/v1.1.0-beta10/install/helm/gloo-mesh-crds/crds/networking.enterprise.mesh.gloo.solo.io_v1beta1_crds.yaml

#### management plane
helm upgrade --install gloo-mesh-enterprise gloo-mesh-enterprise/gloo-mesh-enterprise --kube-context $MGMT_CONTEXT -n gloo-mesh --version=1.1.0-beta11 --set licenseKey=${GLOO_MESH_LICENSE} --set rbac-webhook.enabled=true --set metricsBackend.prometheus.enabled=true --force

#### leaf clusters
helm ls --kube-context $CLUSTER_1 -n gloo-mesh
helm upgrade --install enterprise-agent --namespace gloo-mesh --kube-context $CLUSTER_1 https://storage.googleapis.com/gloo-mesh-enterprise/enterprise-agent/enterprise-agent-1.1.0-beta11.tgz 


helm ls --kube-context $CLUSTER_2 -n gloo-mesh
helm upgrade --install enterprise-agent --namespace gloo-mesh --kube-context $CLUSTER_2 https://storage.googleapis.com/gloo-mesh-enterprise/enterprise-agent/enterprise-agent-1.1.0-beta11.tgz 



