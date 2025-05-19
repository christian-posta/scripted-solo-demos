source env.sh
source ~/bin/ai-keys

echo "kgateway requires Kubernetes Gateway API to be installed (version v1.2.1)."

# Check if Gateway API is already installed
if kubectl get crd gateways.gateway.networking.k8s.io &>/dev/null; then
    echo "Kubernetes Gateway API is already installed."
    # Get the version from the CRD annotations
    GATEWAY_API_VERSION=$(kubectl get crd gateways.gateway.networking.k8s.io -o jsonpath='{.metadata.annotations.gateway\.networking\.k8s\.io/bundle-version}' 2>/dev/null || echo "unknown")
    echo "Installed version: $GATEWAY_API_VERSION"
    read -p "Do you want to continue with the installation? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation aborted."
        exit 1
    fi
else
    echo "Installing Kubernetes Gateway API..."
    kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.1/standard-install.yaml
fi

helm upgrade -i --create-namespace --namespace kgateway-system --version $KGATEWAY_VERSION kgateway-crds oci://cr.kgateway.dev/kgateway-dev/charts/kgateway-crds

helm upgrade -i -n kgateway-system kgateway oci://cr.kgateway.dev/kgateway-dev/charts/kgateway \
     --set gateway.aiExtension.enabled=true \
     --version $KGATEWAY_VERSION

kubectl apply -f kgateway/gateway.yaml


# Set up OpenAI secret for kgateway
kubectl create secret generic openai-secret -n kgateway-system --from-literal=Authorization=$OPENAI_API_KEY 
kubectl label secret openai-secret -n kgateway-system app=ai-kgateway

kubectl apply -f kgateway/backend.yaml
kubectl apply -f kgateway/httproute.yaml

