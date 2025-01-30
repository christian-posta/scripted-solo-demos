
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

Cleanup:

```bash
kubectl delete namespace common-infra
```

## Setting up Egress (Gloo Gateway Waypoints)

Upgrade Gloo gateway to support waypoints:

```bash
VERSION="1.19.0-beta1-bmain-f7062f9"

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
```
