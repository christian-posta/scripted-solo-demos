CLUSTER_1=$1
TRUST_DOMAIN="${2:-cluster.local}"
STATIC_IP=$3

echo "********************************"
echo "Install Istio onto $CLUSTER_1"
echo "********************************"
istioctl1.8 --context $CLUSTER_1 operator init

kubectl --context $CLUSTER_1 create ns istio-system

cat << EOF | kubectl --context $CLUSTER_1 apply -f -
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  name: istiocontrolplane-default
  namespace: istio-system
spec:
  profile: default
  addonComponents:
    istiocoredns:
      enabled: true
  meshConfig:
    accessLogFile: /dev/stdout
    enableAutoMtls: true
    trustDomain: $TRUST_DOMAIN
  values:
    global:
      trustDomain: $TRUST_DOMAIN
  components:
    ingressGateways:
    - name: istio-ingressgateway
      label:
        topology.istio.io/network: network2
      enabled: true
      k8s:
        env:
          # sni-dnat adds the clusters required for AUTO_PASSTHROUGH mode
          - name: ISTIO_META_ROUTER_MODE
            value: "sni-dnat"
          # traffic through this gateway should be routed inside the network
          - name: ISTIO_META_REQUESTED_NETWORK_VIEW
            value: network2
        service:
          type: LoadBalancer
          loadBalancerIP: $STATIC_IP
          ports:
            - name: http2
              port: 80
              targetPort: 8080
            - name: https
              port: 443
              targetPort: 8443
            - name: tcp-status-port
              port: 15021
              targetPort: 15021
            - name: tls
              port: 15443
              targetPort: 15443
            - name: tcp-istiod
              port: 15012
              targetPort: 15012
            - name: tcp-webhook
              port: 15017
              targetPort: 15017  
    pilot:
      k8s:
        env:
          - name: PILOT_SKIP_VALIDATE_TRUST_DOMAIN
            value: "true"
EOF