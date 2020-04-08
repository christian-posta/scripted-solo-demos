. ./env.sh

# ensure service-mesh-hub ns exists
kubectl create ns --context $CLUSTER_1  service-mesh-hub
kubectl create ns --context $CLUSTER_2  service-mesh-hub

# Install SMH CRDs
meshctl --context $CLUSTER_1 install

kubectl get po -n service-mesh-hub -w

read -s

meshctl --context $CLUSTER_1 check

# Register the different clusters with SMH
meshctl cluster register \
  --remote-context $CLUSTER_1 \
  --remote-cluster-name cluster-1 

meshctl istio install --context $CLUSTER_1 --operator-spec=- <<EOF
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


meshctl istio install --context $CLUSTER_2 --operator-spec=- <<EOF
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

meshctl cluster register \
  --remote-context $CLUSTER_2 \
  --remote-cluster-name cluster-2 

## Get meshes, see that they were discovered
kubectl --context $CLUSTER_1 get meshes -n service-mesh-hub


