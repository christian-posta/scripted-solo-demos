CONTEXT="${1:-ai-demo}"


if [[ "$2" != "skip" ]]; then
  echo "Using kube context: $CONTEXT"
  read -p "Press Enter to continue..."
fi


kubectl --context $CONTEXT apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.0/standard-install.yaml

helm repo add gloo-ee-helm https://storage.googleapis.com/gloo-ee-helm
helm repo update

VERSION="1.18.2"

# if you need to debug the chart, get it like this:
# helm template gloo-ee-helm/gloo-ee --version $VERSION --namespace gloo-system --create-namespace --set license_key=$GLOO_LICENSE_WITH_AI -f -<<EOF

source ~/bin/glooe-license-key-env 
helm upgrade --kube-context $CONTEXT -i gloo-gateway gloo-ee-helm/gloo-ee \
  --version $VERSION \
  --namespace gloo-system --create-namespace \
  --set license_key=$GLOO_LICENSE_WITH_AI \
-f -<<EOF
gloo:
  kubeGateway:
    enabled: true
  gatewayProxies:
    gatewayProxy:
      disabled: true
  discovery:
    enabled: false
gloo-fed:
  enabled: false
  glooFedApiserver:
    enable: false
# disable everything else for a simple deployment
observability:
  enabled: false
prometheus:
  enabled: false
grafana:
  defaultInstallationEnabled: false
gateway-portal-web-server:
  enabled: false
EOF

kubectl --context $CONTEXT apply -f resources/ai-gateway.yaml