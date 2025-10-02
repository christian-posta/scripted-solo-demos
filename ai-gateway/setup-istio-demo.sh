
CONTEXT="${1:-ai-demo}"

./install-istio-ambient.sh $CONTEXT "skip"


# Patch only the gateway pod to be part of ambient; we don't need to include everything in gloo-system (though we could)
kubectl --context $CONTEXT patch deployment/ai-gateway -n gloo-system --patch '{"spec": {"template": {"metadata": {"labels": {"istio.io/dataplane-mode": "ambient","ambient.istio.io/bypass-inbound-capture": "true"}}}}}'


NAMESPACES="${2:-default ollama}"

if [[ -n "$NAMESPACES" ]]; then
  echo "Adding the following namespaces for ambient mode: $NAMESPACES"
  for NAMESPACE in $NAMESPACES; do
    echo "Going to label namespace: $NAMESPACE"
    if ! kubectl --context $CONTEXT label namespace $NAMESPACE "istio.io/dataplane-mode=ambient" --overwrite; then
      echo "Failed to label namespace: $NAMESPACE. It may not exist or is already labeled."
    fi
  done
else
  echo "Not going to add any more namespaces."
fi


### Configure the pod monitor for prometheus in kube-stack
kubectl apply -f ./istio/istio-podmonitor.yaml

### Import all of the Istio dashboards to Grafana
./istio/import-dashboards.sh


### Set up Kiali, and connec it to the Prometheus in kube-stack
helm repo add kiali https://kiali.org/helm-charts
helm repo update

kubectl create ns kiali-operator

KIALI_VERSION=2.0.0
helm install \
    --set cr.create=true \
    --set cr.namespace=istio-system \
    --set cr.spec.auth.strategy="anonymous" \
    --set cr.spec.external_services.prometheus.url="http://kube-prometheus-stack-prometheus.monitoring.svc:9090" \
    --namespace kiali-operator \
    --create-namespace \
    --version $KIALI_VERSION \
    kiali-operator \
    kiali/kiali-operator