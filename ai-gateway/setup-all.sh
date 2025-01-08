

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


kubectl --context $CONTEXT apply -f resources/ai-gateway.yaml

# Set up OpenTelemetry
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm repo update

helm upgrade --install opentelemetry-collector open-telemetry/opentelemetry-collector \
--version 0.97.1 \
--set mode=deployment \
--set image.repository="otel/opentelemetry-collector-contrib" \
--set command.name="otelcol-contrib" \
--namespace=otel \
--create-namespace \
-f ./resources/observability/helm-otel-install.yaml


# Set up Prometheus and Grafana
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm upgrade --install kube-prometheus-stack \
prometheus-community/kube-prometheus-stack \
--version 61.2.0 \
--namespace monitoring \
--create-namespace \
--values ./resources/observability/helm-prom-install.yaml


kubectl apply -f ./resources/observability/pod-monitor.yaml


kubectl -n monitoring create cm envoy-dashboard --from-file=./resources/observability/envoy.json
kubectl label -n monitoring cm envoy-dashboard grafana_dashboard=1