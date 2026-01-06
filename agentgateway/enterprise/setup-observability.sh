# Install components for observability

########################################################
# Install Tempo
########################################################

helm repo add grafana https://grafana.github.io/helm-charts
helm repo update grafana
helm upgrade --install tempo \
grafana/tempo-distributed \
--namespace monitoring \
--create-namespace \
--wait \
--values - <<EOF
minio:
  enabled: false
traces:
  otlp:
    grpc:
      enabled: true
    http:
      enabled: true
  zipkin:
    enabled: false
  jaeger:
    thriftHttp:
      enabled: false
  opencensus:
    enabled: false
EOF


########################################################
# Install Grafana / Prometheus
########################################################
export GRAFANA_ADMIN_PASSWORD="admin"

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update prometheus-community
helm upgrade --install grafana-prometheus \
  prometheus-community/kube-prometheus-stack \
  --version 80.4.2 \
  --namespace monitoring \
  --values - <<EOF
alertmanager:
  enabled: false
grafana:
  adminPassword: "${GRAFANA_ADMIN_PASSWORD:-prom-operator}"
  service:
    type: ClusterIP
    port: 3000
  additionalDataSources:
    - name: Tempo
      type: tempo
      access: proxy
      url: "http://tempo-query-frontend.monitoring.svc.cluster.local:3200"
      uid: 'local-tempo-uid'
  sidecar:
    dashboards:
      enabled: true
      label: grafana_dashboard
      labelValue: "1"
      searchNamespace: monitoring
nodeExporter:
  enabled: false
prometheus:
  service:
    type: ClusterIP
  prometheusSpec:
    ruleSelectorNilUsesHelmValues: false
    serviceMonitorSelectorNilUsesHelmValues: false
    podMonitorSelectorNilUsesHelmValues: false
EOF

########################################################
# Install PodMonitor for agentgateway metrics
########################################################
kubectl apply -f- <<EOF
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: data-plane-monitoring-agentgateway-metrics
  namespace: enterprise-agentgateway
spec:
  namespaceSelector:
    matchNames:
      - enterprise-agentgateway
  podMetricsEndpoints:
    - port: metrics
  selector:
    matchLabels:
      app.kubernetes.io/name: agentgateway
EOF


########################################################
# Install Grafana dashboard
########################################################
kubectl create configmap agentgateway-dashboard \
  --from-file=agentgateway-overview.json=./resources/grafana/agentgateway-grafana-dashboard-v1.json \
  --namespace monitoring \
  --dry-run=client -o yaml | \
kubectl label --local -f - \
  grafana_dashboard="1" \
  --dry-run=client -o yaml | \
kubectl apply -f -


echo "Now you can port forward to Grafana and Prometheus:"
echo "kubectl port-forward -n monitoring svc/grafana-prometheus 3000:3000"
