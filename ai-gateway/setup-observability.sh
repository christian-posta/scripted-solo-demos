

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

kubectl -n monitoring create cm gg-dashboard --from-file=./resources/observability/gw-dashboard.json 
kubectl label -n monitoring cm gg-dashboard grafana_dashboard=1

kubectl -n monitoring create cm llm-dashboard --from-file=./resources/observability/llm-dashboard.json
kubectl label -n monitoring cm llm-dashboard grafana_dashboard=1

helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
helm upgrade -i -n monitoring jaeger jaegertracing/jaeger --values ./resources/observability/jaeger.yaml
kubectl apply -f ./resources/observability/jaeger-upstream.yaml -n gloo-system

kubectl expose deployment jaeger --type=LoadBalancer --name=jaeger-loadbalancer --port=16686 --target-port=16686 -n monitoring

kubectl apply -f ./resources/observability/ai-gateway-parameters.yaml -n gloo-system
