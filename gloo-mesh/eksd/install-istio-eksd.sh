CLUSTER_1=kind-default
TRUST_DOMAIN="${2:-cluster.local}"

echo "********************************"
echo "Install Istio onto $CLUSTER_1"
echo "********************************"
istioctl1.7 --context $CLUSTER_1 operator init

kubectl --context $CLUSTER_1 create ns istio-system
kubectl apply -f istio.yaml
