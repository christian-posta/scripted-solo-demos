# Set namespace (default is "default")
export NS=default

# Set versions (you can modify these as needed)
export INF_EXT_VERSION="v0.2.0"
export GATEWAY_API_VERSION="v1.2.1"
export GATEWAY_API_CHANNEL="experimental"
export KGTW_VERSION="v2.0.0-main"

# Install Gateway API CRDs
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/${GATEWAY_API_VERSION}/${GATEWAY_API_CHANNEL}-install.yaml

# Install Inference Extension CRDs
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api-inference-extension/releases/download/${INF_EXT_VERSION}/manifests.yaml

# Create the kgateway-system namespace
kubectl create namespace kgateway-system

# Install kgateway CRDs using Helm
helm upgrade --install kgateway-crds oci://cr.kgateway.dev/kgateway-dev/charts/kgateway-crds \
  -n kgateway-system \
  --create-namespace \
  --version "${KGTW_VERSION}"

# Install kgateway controller using Helm
# note, for v2.0.0 when it's released the only value we'll need is that to enable inferenceExtension
helm upgrade --install kgateway oci://cr.kgateway.dev/kgateway-dev/charts/kgateway  \
  -n kgateway-system \
  --set inferenceExtension.enabled=true \
  --set gatewayClass.service.type="LoadBalancer" \
  --set controller.image.pullPolicy=Always \
  --set image.registry=ghcr.io/kgateway-dev \
  --version "${KGTW_VERSION}"

# Wait for the kgateway GatewayClass to become accepted
# This uses the check_gatewayclass_status function from utils.sh
kubectl wait --for=condition=Accepted gatewayclass/kgateway --timeout=5m

# Check if kgateway controller is running
kubectl rollout status deployment kgateway -n kgateway-system