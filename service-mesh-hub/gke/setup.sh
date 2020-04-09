. ./env.sh

# ensure service-mesh-hub ns exists
#kubectl create ns --context $CLUSTER_1  service-mesh-hub
#kubectl create ns --context $CLUSTER_2  service-mesh-hub

# Install SMH CRDs
#echo "********************************"
#echo "Installing SMH onto $CLUSTER_1"
#echo "********************************"

#meshctl --context $CLUSTER_1 install

#kubectl get po -n service-mesh-hub -w


#echo "********************************"
#echo "Checking the SMH deployment"
#echo "********************************"
#read -s
#meshctl --context $CLUSTER_1 check


#echo "********************************"
#echo "Registering Cluster 1"
#echo "********************************"
# Register the different clusters with SMH
#meshctl cluster register \
#  --remote-context $CLUSTER_1 \
#  --remote-cluster-name cluster-1 

echo "********************************"
echo "Install Istio onto cluster 1"
echo "********************************"
read -s
meshctl mesh install istio --context $CLUSTER_1 --operator-spec=- <<EOF
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  name: example-istiooperator
  namespace: istio-operator
spec:
  profile: minimal
  components:
    # Istio Gateway feature
    ingressGateways:
    - name: istio-ingressgateway
      enabled: true
      k8s:
        env:
          - name: ISTIO_META_ROUTER_MODE
            value: "sni-dnat"
          - name: PILOT_CERT_PROVIDER
            value: "kubernetes"
  values:
    global:
      pilotCertProvider: kubernetes
      controlPlaneSecurityEnabled: true
      mtls:
        enabled: true
      podDNSSearchNamespaces:
      - global
      - '{{ valueOrDefault .DeploymentMeta.Namespace "default" }}.global'
    security:
      selfSigned: false
EOF

echo "Wait for Istio to come up on Cluster 1"
kubectl get po -n istio-system -w

#echo "********************************"
#echo "Update DNS on Cluster 1"
#echo "********************************"
#kubectl --context $CLUSTER_1 apply -f - <<EOF
#apiVersion: v1
#kind: ConfigMap
#metadata:
#  name: kube-dns
#  namespace: kube-system
#data:
#  stubDomains: |
#    {"global": ["$(kubectl --context $CLUSTER_1 get svc -n istio-system istiocoredns -o jsonpath={.spec.clusterIP})"]}
#EOF


echo "********************************"
echo "Installing Istio onto Cluster 2"
echo "********************************"
read -s
meshctl mesh install istio --context $CLUSTER_2 --operator-spec=- <<EOF
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  name: example-istiooperator
  namespace: istio-operator
spec:
  profile: minimal
  components:
    # Istio Gateway feature
    ingressGateways:
    - name: istio-ingressgateway
      enabled: true
      k8s:
        env:
          - name: ISTIO_META_ROUTER_MODE
            value: "sni-dnat"
          - name: PILOT_CERT_PROVIDER
            value: "kubernetes"
  values:
    global:
      pilotCertProvider: kubernetes
      controlPlaneSecurityEnabled: true
      mtls:
        enabled: true
      podDNSSearchNamespaces:
      - global
      - '{{ valueOrDefault .DeploymentMeta.Namespace "default" }}.global'
    security:
      selfSigned: false
EOF

echo "Wait for Istio to come up on Cluster 2"
kubectl get po -n istio-system -w

#echo "********************************"
#echo "Update DNS on Cluster 2"
#echo "********************************"
#kubectl --context $CLUSTER_2 apply -f - <<EOF
#apiVersion: v1
#kind: ConfigMap
#metadata:
#  name: kube-dns
#  namespace: kube-system
#data:
#  stubDomains: |
#    {"global": ["$(kubectl --context $CLUSTER_2 get svc -n istio-system istiocoredns -o jsonpath={.spec.clusterIP})"]}
#EOF


#echo "********************************"
#echo "Register Cluster 2"
#echo "********************************"
#meshctl cluster register \
#  --remote-context $CLUSTER_2 \
#  --remote-cluster-name cluster-2 

#echo "********************************"
#echo "Verify meshes were created and discovered"
#echo "********************************"
#read -s
## Get meshes, see that they were discovered
#kubectl --context $CLUSTER_1 get meshes -n service-mesh-hub -w

## Install Bookinfo on cluster 1
kubectl label --context $CLUSTER_1 namespace default istio-injection=enabled --overwrite
kubectl apply -f ../resources-common/bookinfo-cluster1.yaml --context $CLUSTER_1

## Install Bookinfo on cluster 2
kubectl label namespace default istio-injection=enabled --context $CLUSTER_2 --overwrite
kubectl apply -f ../resources-common/bookinfo-cluster2.yaml --context $CLUSTER_2



