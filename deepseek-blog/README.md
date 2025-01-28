In this guide, we will deploy an AI Gateway to apply policy to DeepSeek R1 calls:

```bash
curl -v https://api.deepseek.com/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $DEEPSEEK_API_KEY" \
  -d '{
        "model": "deepseek-chat",
        "messages": [
          {"role": "user", "content": "Hello!"}
        ],
        "stream": false
      }'
```


### Deploy KGateway

```bash
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.0/standard-install.yaml

helm repo add gloo-ee-helm https://storage.googleapis.com/gloo-ee-helm
helm repo update

VERSION="1.18.2"

source ~/bin/glooe-license-key-env 
helm upgrade -i gloo-gateway gloo-ee-helm/gloo-ee \
  --version $VERSION \
  --namespace gloo-system --create-namespace \
  --set license_key=$GLOO_LICENSE_WITH_AI \
-f kgateway-values.yaml

kubectl apply -f ai-gateway.yaml
```


### Set up Gateway To Route to DeepSeek

```bash
source ~/bin/ai-keys
kubectl create secret generic deepseek-secret -n gloo-system \
    --from-literal="Authorization=Bearer $DEEPSEEK_API_KEY" \
    --dry-run=client -oyaml | kubectl apply -f -

kubectl create secret generic openai-secret -n gloo-system \
    --from-literal="Authorization=Bearer $OPENAI_KEY" \
    --dry-run=client -oyaml | kubectl apply -f -    
```

Demo:
* Calling out to DeepSeek 
* Prompt Guard the call
* Traffic Split to Local
* All traffic to Local
* Secure the call with JWT
* Metrics

### Setup GKE Clusters with NVIDIA L4 inferencing GPUs

https://cloud.google.com/compute/docs/gpus#l4-gpus

```bash
source env.sh
gcloud container clusters create $CLUSTER_NAME \
    --zone $ZONE \
    --region $REGION \
    --node-locations $ZONE \
    --release-channel "regular" \
    --machine-type "n1-standard-8" \
    --image-type "UBUNTU_CONTAINERD" \
    --disk-type "pd-standard" \
    --disk-size "100" \
    --no-enable-intra-node-visibility \
    --metadata disable-legacy-endpoints=true \
    --max-pods-per-node "110" \
    --num-nodes "2" \
    --logging=SYSTEM,WORKLOAD \
    --monitoring=SYSTEM \
    --enable-ip-alias \
    --default-max-pods-per-node "110" \
    --no-enable-master-authorized-networks
```

```bash
gcloud container node-pools create gpu-pool \
    --cluster $CLUSTER_NAME \
    --zone $ZONE \
    --node-locations $ZONE \
    --machine-type "g2-standard-8" \
    --image-type "UBUNTU_CONTAINERD" \
    --node-labels="gke-no-default-nvidia-gpu-device-plugin=true" \
    --metadata disable-legacy-endpoints=true \
    --disk-size "100" \
    --num-nodes "1" \
    --tags=nvidia-ingress-all
```

Install GPU Operator to manage GPU resources, containerd toolkits, and GPU device plugins.

```bash
helm repo add nvidia https://helm.ngc.nvidia.com/nvidia
helm repo update

export GPU_OPERATOR_VERSION=v24.9.1
kubectl create namespace gpu-operator
kubectl apply -f ./gke-resourcequota.yaml
helm upgrade --install gpu-operator nvidia/gpu-operator --wait  \
    -n gpu-operator \
    --version=$GPU_OPERATOR_VERSION \
    -f ./gpu-operator-values.yaml \
    --timeout 3m
```

Verify GPU nodes are properly recognized
```bash
kubectl get nodes "-o=custom-columns=NAME:.metadata.name,GPU:.status.allocatable.nvidia\.com/gpu"
```

Verify with nvidia-smi
```bash
POD=$(kubectl get pods -n gpu-operator -l app=nvidia-driver-daemonset -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it $POD -n gpu-operator -- nvidia-smi
```