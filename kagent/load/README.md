# Fortio Load Tester for Kubernetes

This directory contains everything needed to build and deploy a containerized load testing solution using Fortio for Istio Bookinfo (or any other service).

## Contents

- `run-load.sh` - The load testing script that simulates various traffic patterns
- `Dockerfile` - For building the container image
- `k8s-manifests/` - Kubernetes deployment manifests
  - `deployment.yaml` - Deployment configuration
  - `configmap.yaml` - ConfigMap for environment variables
  - `kustomization.yaml` - Kustomize manifest to deploy all resources

## Build the Docker Image

```bash
# Navigate to the load directory
cd load

# Build the Docker image
docker build -t fortio-load:latest .

# Optionally, tag and push to a container registry
docker tag fortio-load:latest your-registry/fortio-load:latest
docker push your-registry/fortio-load:latest
```

You may want to load this into a kind cluster:

```bash
kind load docker-image fortio-load:latest --name kind1
```

## Deploy to Kubernetes

### Option 1: Apply manifests directly

```bash
# Create the Kubernetes resources
kubectl apply -f k8s-manifests/configmap.yaml
kubectl apply -f k8s-manifests/deployment.yaml
```

### Option 2: Using Kustomize

```bash
# Deploy using kustomize
kubectl apply -k k8s-manifests/

# Or with custom image registry and tag
IMAGE_REGISTRY=your-registry IMAGE_TAG=v1.0.0 kubectl apply -k k8s-manifests/
```

## Configuration

You can customize the load testing by editing the ConfigMap:

```bash
kubectl edit configmap fortio-load-config
```

Available environment variables:
- `GATEWAY_URL`: The URL of your gateway (default: http://istio-ingressgateway.istio-system.svc.cluster.local)
- `PRODUCTPAGE_PATH`: The path to the product page (default: /productpage)

## View Logs

```bash
# Get the pod name
POD_NAME=$(kubectl get pods -l app=fortio-load-tester -o jsonpath='{.items[0].metadata.name}')

# Stream logs
kubectl logs -f $POD_NAME
```

## Access Logs During Runtime

The logs are stored in an emptyDir volume mounted at `/app/fortio-logs` in the container. These logs are ephemeral and will be lost when the pod is restarted or terminated.

```bash
# To copy logs from the pod to your local machine during runtime
kubectl cp $POD_NAME:/app/fortio-logs ./local-fortio-logs
``` 