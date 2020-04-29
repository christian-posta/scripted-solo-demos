CLUSTER_1=$1

echo "********************************"
echo "Install Istio onto $CLUSTER_1"
echo "********************************"
#read -s
meshctl mesh install istio --context $CLUSTER_1 --operator-spec=- <<EOF
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  name: example-istiooperator
  namespace: istio-operator
spec:
  profile: minimal
  addonComponents:
    istiocoredns:
      enabled: true
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

#echo "Wait for Istio to come up on $CLUSTER_1"
#kubectl get po -n istio-system -w


#echo "********************************"
#echo "Update DNS on Cluster 2"
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

