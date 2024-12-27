

./setup-kind.sh

CONTEXT="${1:-ai-demo}"

kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.0/standard-install.yaml

helm repo add gloo-ee-helm https://storage.googleapis.com/gloo-ee-helm
helm repo update

source ~/bin/glooe-license-key-env 
helm upgrade --kube-context $CONTEXT -i gloo-gateway gloo-ee-helm/gloo-ee \
  --version 1.18.0 \
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



# create tokens here..
source ~/bin/ai-keys

#openai token
kubectl --context $CONTEXT create secret generic openai-secret -n gloo-system \
    --from-literal="Authorization=Bearer $OPENAI_KEY" \
    --dry-run=client -oyaml | kubectl apply -f -

#mistral token
kubectl --context $CONTEXT create secret generic mistralai-secret -n gloo-system \
    --from-literal="Authorization=Bearer $MISTRAL_KEY" \
    --dry-run=client -oyaml | kubectl apply -f -

kubectl --context $CONTEXT apply -f resources/ai-gateway.yaml