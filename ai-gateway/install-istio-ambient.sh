CONTEXT="${1:-ai-demo}"

if [[ "$2" != "skip" ]]; then
  echo "Using kube context: $CONTEXT"
  read -p "Press Enter to continue..."
fi

# Install the Gateway API CRDs if they don't exist
kubectl --context $CONTEXT get crd gateways.gateway.networking.k8s.io &> /dev/null || \
  { kubectl --context $CONTEXT apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.0/standard-install.yaml; }


helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update


# Install Control Plane
helm install istio-base istio/base -n istio-system --create-namespace --wait --kube-context $CONTEXT
helm install istiod istio/istiod --namespace istio-system --set profile=ambient --wait --kube-context $CONTEXT
helm install istio-cni istio/cni -n istio-system --set profile=ambient --wait --kube-context $CONTEXT

# Install the Data Plane
helm install ztunnel istio/ztunnel -n istio-system --wait --kube-context $CONTEXT





