CONTEXT="${1:-ai-demo}"
ISTIO_VERSION="1.25.0-alpha.66a82c15dc64247415869e35df4bab9bbfbe3afc"
ISTIO_DIR="/home/solo/dev/istio/istio-1.25-alpha.66a82c15dc64247415869e35df4bab9bbfbe3afc"

if [[ "$2" != "skip" ]]; then
  echo "Using kube context: $CONTEXT"
  read -p "Press Enter to continue..."
fi

# Install the Gateway API CRDs if they don't exist
kubectl --context $CONTEXT get crd gateways.gateway.networking.k8s.io &> /dev/null || \
  { kubectl --context $CONTEXT apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.0/standard-install.yaml; }


# Install Control Plane
#helm show values istio/base --version $ISTIO_VERSION
helm upgrade --install istio-base "$ISTIO_DIR/manifests/charts/base" -n istio-system --create-namespace --wait --kube-context $CONTEXT


#helm show values istio/istiod --version $ISTIO_VERSION
helm upgrade --install istiod "$ISTIO_DIR/manifests/charts/istio-control/istio-discovery" --namespace istio-system --set profile=ambient --set pilot.env.PILOT_ENABLE_IP_AUTOALLOCATE=true --wait --kube-context $CONTEXT

#helm show values istio/cni --version $ISTIO_VERSION
helm upgrade --install istio-cni "$ISTIO_DIR/manifests/charts/istio-cni" -n istio-system --set profile=ambient --set ambient.dnsCapture=true  --wait --kube-context $CONTEXT

# Install the Data Plane
#helm show values istio/ztunnel --version $ISTIO_VERSION
helm upgrade --install ztunnel "$ISTIO_DIR/manifests/charts/ztunnel" -n istio-system --wait --kube-context $CONTEXT





