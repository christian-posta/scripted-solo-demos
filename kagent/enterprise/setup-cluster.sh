
source ~/bin/gloo-license-key-env 

read -p "Make sure keycloak is installed first. Press enter to continue"

# Check for keycloak-agent-identity pod in Running state
POD_STATUS=$(kubectl get pod -n default -l app=keycloak-agent-identity -o jsonpath='{.items[0].status.phase}' 2>/dev/null)
if [[ "$POD_STATUS" != "Running" ]]; then
  echo "ERROR: keycloak-agent-identity pod is not in Running state in the 'default' namespace."
  echo "Current pod status: ${POD_STATUS:-Not Found}"
  exit 1
fi

# Check for keycloak setup job in Completed state
SETUP_JOB_STATUS=$(kubectl get job keycloak-setup -n default -o jsonpath='{.status.conditions[?(@.type=="Complete")].status}' 2>/dev/null)
if [[ "$SETUP_JOB_STATUS" != "True" ]]; then
  echo "WARNING: keycloak-setup job not found or not completed in the 'default' namespace."
  echo "Continuing since keycloak-agent-identity pod is running."
fi


# install the gloo operator
helm install gloo-operator oci://us-docker.pkg.dev/solo-public/gloo-operator-helm/gloo-operator \
--version 0.3.1 \
-n kagent \
--create-namespace \
--set manager.env.SOLO_ISTIO_LICENSE_KEY=${SOLO_LICENSE_KEY}

kubectl wait --for=condition=Ready pod -l app.kubernetes.io/name=gloo-operator -n kagent --timeout=180s

# install gateway CRDs
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/standard-install.yaml

# install ambient ztunnel
kubectl apply -n kagent -f - <<EOF
apiVersion: operator.gloo.solo.io/v1
kind: ServiceMeshController
metadata:
  name: managed-istio
  labels:
    app.kubernetes.io/name: managed-istio
spec:
  dataplaneMode: Ambient
  installNamespace: istio-system
  version: 1.27.1
EOF


kubectl wait --for=condition=Ready pod -n istio-system --all --timeout=180s


# Install kgateway / gloo gateway
helm upgrade -i kgateway-crds oci://cr.kgateway.dev/kgateway-dev/charts/kgateway-crds \
--namespace kgateway-system --create-namespace \
--version v2.1.0-main \
--set controller.image.pullPolicy=Always \
--set controller.image.registry=docker.io \
--set controller.image.repository=howardjohn/kgateway \
--set controller.image.tag=1756156487

helm upgrade -i kgateway oci://cr.kgateway.dev/kgateway-dev/charts/kgateway \
--namespace kgateway-system \
--version v2.1.0-main \
--set agentGateway.enabled=true \
--set agentGateway.enableAlphaAPIs=true \
--set controller.image.registry=docker.io \
--set controller.image.repository=howardjohn/kgateway \
--set controller.image.tag=1756156487

kubectl wait --for=condition=Ready pod -n kgateway-system --all --timeout=180s

# Install kagent-enterprise
helm upgrade -i kagent-enterprise \
oci://us-docker.pkg.dev/solo-public/kagent-enterprise-helm/charts/management \
-n kagent --create-namespace \
--version 0.1.0 \
--values ./kagent-oidc-config.yaml \
--set cluster=nim-cluster

kubectl wait --for=condition=Ready pod -n kagent --all --timeout=180s

# Install kagent OSS
helm upgrade -i kagent-crds \
oci://ghcr.io/kagent-dev/kagent/helm/kagent-crds \
-n kagent \
--version 0.6.12

helm upgrade -i kagent \
oci://ghcr.io/kagent-dev/kagent/helm/kagent \
-n kagent \
--version 0.6.12 \
--values - <<EOF
providers:
  openAI:
    apiKey: ${OPENAI_API_KEY}
otel:
  tracing:
    enabled: true
    exporter:
      otlp:
        endpoint: kagent-enterprise-ui.kagent.svc.cluster.local:4317
        insecure: true
kagent-tools:
  openAI:
    apiKey: ${OPENAI_API_KEY}
  otel:
    tracing:
      enabled: true
      exporter:
        otlp:
          endpoint: kagent-enterprise-ui.kagent.svc.cluster.local:4317
          insecure: true
EOF

kubectl wait --for=condition=Ready pod -n kagent --all --timeout=180s
