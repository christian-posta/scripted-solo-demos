
source env.sh


# Set up Prometheus and Grafana for the kube-prometheus-stack
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm upgrade --install kube-prometheus-stack \
prometheus-community/kube-prometheus-stack \
--version 61.2.0 \
--namespace monitoring \
--create-namespace \
--values ./resources/observability/helm-prom-install.yaml

# Default un/pw for grafana is admin/prom-operator


### Configure the pod monitor for prometheus in kube-stack
kubectl apply -f ./resources/istio/istio-podmonitor.yaml

### Import all of the Istio dashboards to Grafana
./resources/istio/import-dashboards.sh


### Set up Kiali, and connec it to the Prometheus in kube-stack
helm repo add kiali https://kiali.org/helm-charts
helm repo update

kubectl create ns kiali-operator

# need this since this is where kiali will look for CRs
kubectl create ns istio-system

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