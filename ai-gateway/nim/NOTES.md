export CLUSTER_NAME="ceposta-nim-cluster"
export REGION="us-central1"
export ZONE="us-central1-a"

gcloud container clusters create $CLUSTER_NAME \
    --num-nodes 3 \
    --machine-type "e2-standard-4" \
    --enable-ip-alias \
    --cluster-version latest

gcloud container node-pools create "gpu-pool" \
    --cluster $CLUSTER_NAME \
    --machine-type "n1-standard-8" \
    --accelerator type=nvidia-tesla-t4,count=1 \
    --num-nodes 1 \
    --enable-autoscaling \
    --min-nodes 1 \
    --max-nodes 2    

helm repo add nvidia https://helm.ngc.nvidia.com/nvidia
helm repo update

kubectl create namespace gpu-operator

helm upgrade --install gpu-operator nvidia/gpu-operator --wait  \
    -n gpu-operator \
    --set driver.enabled=false \
    --set toolkit.enabled=true \
    --set devicePlugin.enabled=true \
    --set dcgmExporter.enabled=true \
    --set dcgmExporter.config.name="" \
    --set operator.priorityClassName="" \
    --set driver.priorityClassName="" \
    --set toolkit.priorityClassName="" \
    --set devicePlugin.priorityClassName="" \
    --set dcgmExporter.priorityClassName="" \
    --set nodeStatusExporter.priorityClassName="" \
    --set gfd.priorityClassName="" \
    --set driver.repository=gcr.io/gke-release/nvidia-driver \
    --set driver.version=latest \
    --version=v23.9.1 \
    --timeout 10m


## Verify

# Verify GPU nodes are properly recognized
kubectl get nodes "-o=custom-columns=NAME:.metadata.name,GPU:.status.allocatable.nvidia\.com/gpu"


## Install NIM Operator
source ~/bin/ai-keys

kubectl create namespace nvidia-nim

kubectl create secret docker-registry ngc-secret \
    --docker-server=nvcr.io \
    --docker-username='$oauthtoken' \
    --docker-password='$NGC_API_KEY' \
    --docker-email='christian.posta@gmail.com' \
    -n nvidia-nim


helm repo add nvidia https://helm.ngc.nvidia.com/nvidia
helm repo update

# Install NIM operator
helm upgrade --install nim-operator nvidia/k8s-nim-operator --wait  \
    -n nvidia-nim \
    --version=v1.0.1 \
    --set global.registry.secretName=ngc-secret




---- finished here ------

# Create secret for OpenAI API key (replace YOUR_OPENAI_API_KEY with your key)
kubectl create secret generic openai-secret \
    --from-literal=api-key='YOUR_OPENAI_API_KEY' \
    -n nvidia-nim

# Deploy a NIM model service using OpenAI API
cat <<EOF | kubectl apply -f -
apiVersion: nim.nvidia.com/v1
kind: InferenceService
metadata:
  name: openai-proxy
  namespace: nvidia-nim
spec:
  modelName: openai
  modelVersion: "1"
  replicas: 1
  modelConfigName: gpt-3.5-turbo
  resources:
    limits:
      cpu: "2"
      memory: "4Gi"
    requests:
      cpu: "1"
      memory: "2Gi"
  env:
    - name: OPENAI_API_KEY
      valueFrom:
        secretKeyRef:
          name: openai-secret
          key: api-key
EOF

# Wait for the service to be ready
kubectl wait --for=condition=ready inferenceservice openai-proxy -n nvidia-nim --timeout=300s

# Create a test pod for querying the model
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: nim-test
  namespace: nvidia-nim
spec:
  containers:
  - name: nim-test
    image: curlimages/curl
    command: ["sleep", "infinity"]
EOF

# Wait for test pod to be ready
kubectl wait --for=condition=ready pod/nim-test -n nvidia-nim --timeout=60s

# Test the model (run this after the pods are ready)
kubectl exec -it nim-test -n nvidia-nim -- curl -X POST \
    http://openai-proxy.nvidia-nim.svc.cluster.local:8000/v2/models/openai/infer \
    -H "Content-Type: application/json" \
    -d '{
      "inputs": [{"text": "What is machine learning?"}]
    }'





# Check all GPU operator pods are running
kubectl get pods -n gpu-operator

## Debugging events
kubectl get events -n gpu-operator --sort-by='.lastTimestamp'


## Clean up

helm uninstall -n gpu-operator $(helm list -n gpu-operator -q)
kubectl delete namespace gpu-operator
kubectl create namespace gpu-operator

gcloud container node-pools delete gpu-pool --cluster $CLUSTER_NAME --zone us-central1-a
gcloud container clusters delete $CLUSTER_NAME --zone us-central1-a
