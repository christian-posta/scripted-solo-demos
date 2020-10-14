CLUSTER_1=$1
TRUST_DOMAIN="${2:-cluster.local}"

echo "********************************"
echo "Install Istio onto $CLUSTER_1"
echo "********************************"
istioctl1.7 --context $CLUSTER_1 operator init

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
    pilot:
      k8s:
        env:
          - name: PILOT_SKIP_VALIDATE_TRUST_DOMAIN
            value: "true"
EOF