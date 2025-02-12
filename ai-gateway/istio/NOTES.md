
Start by running:

./setup-istio-demo.sh


## Setting up Egress (Default Waypoints)

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

Login to the sleep pod and curl the httpbin service:

```bash
kubectl exec -it deploy/sleep -n common-infra -- /bin/sh

curl httpbin.org/get
```

Cleanup:

```bash
kubectl delete namespace common-infra
```

## Setting up Egress (Gloo Gateway Waypoints)

Upgrade Gloo gateway to support waypoints:

# VERSION="1.19.0-beta1-bmain-f7062f9"
# VERSION="1.19.0-beta3-bmain-70beacc"
# VERSION="1.19.0-beta3-bstevenctlwaypoint-cidr-ipv-6218fe9"

```bash
CONTEXT="ai-demo"
VERSION="1.19.0-beta3-bmain-70beacc"

source ~/bin/glooe-license-key-env 
helm upgrade --kube-context $CONTEXT -i gloo-gateway gloo-ee-test/gloo-ee \
  --version $VERSION \
  --namespace gloo-system --create-namespace \
  --set license_key=$GLOO_LICENSE_WITH_AI \
-f ./istio/gloo-gateway-values.yaml
```

Create a waypoint for the egress gateway:

```bash
kubectl create namespace common-infra
kubectl label namespace common-infra istio.io/dataplane-mode=ambient
kubectl apply -f ./istio/gloo-egress-waypoint.yaml
kubectl label ns common-infra istio.io/use-waypoint=gloo-egress-waypoint
kubectl apply -f ./istio/sleep.yaml -n common-infra
kubectl apply -f ./istio/httpbin-serviceentry.yaml
```

```bash
kubectl patch deployment/gloo-proxy-gloo-egress-waypoint -n common-infra --patch '{"spec": {"template": {"metadata": {"annotations": {"ambient.istio.io/dns-capture": "false"}}}}}'
```


### Digging into the AI stuff


