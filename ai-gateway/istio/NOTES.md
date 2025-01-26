

#### Make sure the right namespaces are labeled
E.g:

```bash
kubectl label namespace default istio.io/dataplane-mode=ambient
```

#### Set up Prometheus
```bash
kubectl apply -f ./istio-podmonitor.yaml
```

#### Import Grafana Dashboards
```bash
./istio/import-dashboards.sh
```

#### Set up Kiali

```bash
helm repo add kiali https://kiali.org/helm-charts
helm repo update

#helm search repo kiali/kiali-operator --versions
#helm show values kiali/kiali-operator

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
```


## Setting up Egress

```bash
kubectl create namespace common-infra
kubectl label namespace common-infra istio.io/dataplane-mode=ambient
istioctl waypoint apply --enroll-namespace --name egress-gateway --namespace common-infra
```

```bash
kubectl apply -f ./istio/sleep.yaml -n common-infra
```

Create a service entry for the external host:

```bash
kubectl apply -f ./istio/httpbin-serviceentry.yaml
```



