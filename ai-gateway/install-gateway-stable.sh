if [ -n "$1" ]; then
  CONTEXT="$1"
else
  CONTEXT=$(kubectl config current-context)
fi


if [[ "$2" != "skip" ]]; then
  echo "Using kube context: $CONTEXT"
  read -p "Press Enter to continue..."
fi


kubectl --context $CONTEXT apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/experimental-install.yaml


source ~/bin/gloo-license-key-env 
helm repo add gloo-ee-helm https://storage.googleapis.com/gloo-ee-helm
helm repo update

VERSION="2.0.0-rc.2"

# Install the Gloo Gateway CRDs
helm upgrade -i gloo-gateway-crds oci://us-docker.pkg.dev/solo-public/gloo-gateway/charts/gloo-gateway-crds \
  --create-namespace \
  --namespace gloo-system \
  --version $VERSION

helm upgrade -i gloo-gateway oci://us-docker.pkg.dev/solo-public/gloo-gateway/charts/gloo-gateway \
  -n gloo-system \
  --version $VERSION \
  --set licensing.glooGatewayLicenseKey=$GLOO_GATEWAY_LICENSE_KEY \
  --set licensing.agentgatewayLicenseKey=$AGENTGATEWAY_LICENSE_KEY \
  -f ./gloo-gateway-values.yaml


kubectl --context $CONTEXT apply -f resources/ai-gateway.yaml