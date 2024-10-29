
Create a plain-old KinD cluster:

```bash
/home/solo/scripted-solo-demos/ambient/scripts/setup-kind.sh
```

Install Gatway APIs:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml
```

Prepare customized Gloo image:

```bash
gcloud auth configure-docker us-west2-docker.pkg.dev
docker-image us-west2-docker.pkg.dev/octo-386314/gloo-waypoint/gloo-ee:latest
kind load docker-image us-west2-docker.pkg.dev/octo-386314/gloo-waypoint/gloo-ee:latest
```

Install Gloo:

```bash
export GLOO_MESH_LICENSE_KEY=<TODO!>
helm install -n gloo-system gloo --create-namespace gloo-ee-chart --set gloo.kubeGateway.enabled=true --set license_key="$GLOO_MESH_LICENSE_KEY"
```

Install Istio (with ambient, 1.22+):

```bash
istioctl install --set profile=ambient
istioctl version
```

Deploy demo app and waypoint:

```bash
export DEMO_NS=demo
kubectl create namespace $DEMO_NS
kubectl label namespace $DEMO_NS istio.io/dataplane-mode=ambient
kubectl -n $DEMO_NS apply -f waypoint/01-apps.yaml 
kubectl -n $DEMO_NS apply -f waypoint/02-gloo-waypoint.yaml
kubectl -n $DEMO_NS get pod
export CLIENT=$(kubectl -n $DEMO_NS get po -lapp=sleep -ojsonpath='{.items[0].metadata.name}')
```

Send some traffic:

```bash
send_traffic() {
    kubectl exec -n $DEMO_NS $CLIENT -- curl -sS  helloworld:5000/hello  -v
}
send_traffic
```

Nothing special. Apply an HTTPRoute to see that L7 processing is working (see headers):

```bash
kubectl -n $DEMO_NS apply -f waypoint/03-httproute-gwapi.yaml
```

Next, try using Gloo's RouteOption API to customize headers:

```bash
kubectl -n $DEMO_NS delete -f waypoint/03-httproute-gwapi.yaml
kubectl -n $DEMO_NS apply -f waypoint/04-routeoption-gloo.yaml
```

Now try JWT auth. Update the RouteOption and add a VirtualHostOption to enable JWT auth.

```bash
kubectl -n $DEMO_NS apply -f waypoint/05-jwt-auth.yaml
```

Traffic should be denied. Grab a JWT and send it with the request:

```bash
source waypoint/jwt.sh
send_traffic() {
    kubectl exec -n $DEMO_NS $CLIENT -- curl -sS -H "Authorization: Bearer $JWT" helloworld:5000/hello  -v
}
send_traffic
```
