

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


kubectl apply -f ./resources/observability/pod-monitor.yaml -n otel


kubectl -n monitoring create cm envoy-dashboard --from-file=./resources/observability/envoy.json
kubectl label -n monitoring cm envoy-dashboard grafana_dashboard=1