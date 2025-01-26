CONTEXT="${1:-ai-demo}"
ISTIO_VERSION="1.24.2"

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
#helm show values istio/base --version $ISTIO_VERSION
helm upgrade --install istio-base istio/base -n istio-system --version $ISTIO_VERSION --create-namespace  --wait --kube-context $CONTEXT


#helm show values istio/istiod --version $ISTIO_VERSION
helm upgrade --install istiod istio/istiod --namespace istio-system --version $ISTIO_VERSION --set profile=ambient --set pilot.env.PILOT_ENABLE_IP_AUTOALLOCATE=true --wait --kube-context $CONTEXT

#helm show values istio/cni --version $ISTIO_VERSION
helm upgrade --install istio-cni istio/cni -n istio-system --version $ISTIO_VERSION --set profile=ambient --set ambient.dnsCapture=true  --wait --kube-context $CONTEXT

# Install the Data Plane
#helm show values istio/ztunnel --version $ISTIO_VERSION
helm upgrade --install ztunnel istio/ztunnel -n istio-system --version $ISTIO_VERSION --wait --kube-context $CONTEXT





