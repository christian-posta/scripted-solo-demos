# Set namespace (default is "default")
export NS=default

# Set versions (you can modify these as needed)
export INF_EXT_VERSION="v0.2.0"
export GATEWAY_API_VERSION="v1.2.1"
export GATEWAY_API_CHANNEL="experimental"
export KGTW_VERSION="1.0.1-dev"

# Install Gateway API CRDs
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/${GATEWAY_API_VERSION}/${GATEWAY_API_CHANNEL}-install.yaml

# Install Inference Extension CRDs
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api-inference-extension/releases/download/${INF_EXT_VERSION}/manifests.yaml

# Create the kgateway-system namespace
kubectl create namespace kgateway-system

# Install kgateway CRDs using Helm
helm upgrade --install kgateway-crds https://github.com/danehans/toolbox/raw/refs/heads/main/charts/8836480ba3-kgateway-crds-${KGTW_VERSION}.tgz \
  -n kgateway-system \
  --create-namespace \
  --version "${KGTW_VERSION}"

# Install kgateway controller using Helm
helm upgrade --install kgateway https://github.com/danehans/toolbox/raw/refs/heads/main/charts/8836480ba3-kgateway-${KGTW_VERSION}.tgz \
  -n kgateway-system \
  --set image.registry="danehans" \
  --set controller.image.pullPolicy="Always" \
  --set inferenceExtension.enabled=true \
  --set gatewayClass.service.type="LoadBalancer" \
  --version "${KGTW_VERSION}"

# Wait for the kgateway GatewayClass to become accepted
# This uses the check_gatewayclass_status function from utils.sh
kubectl wait --for=condition=Accepted gatewayclass/kgateway --timeout=5m

# Check if kgateway controller is running
kubectl rollout status deployment kgateway -n kgateway-system