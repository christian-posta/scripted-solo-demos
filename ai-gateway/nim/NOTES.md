source .env.sh

## Create cluster

Based on this documentation: 
https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/google-gke.html


Create a cluster with CPU nodes and we'll add GPU nodes later
```bash
gcloud container clusters create $CLUSTER_NAME \
    --zone $ZONE \
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

Use the following machine type: a2-highgpu-1g from here:
https://cloud.google.com/compute/docs/gpus#a100-gpus

Don't install the default GPU device plugin because we will do that with the GPU Operator.

```bash
gcloud container node-pools create gpu-pool \
    --cluster $CLUSTER_NAME \
    --zone $ZONE \
    --node-locations $ZONE \
    --machine-type "g2-standard-16" \
    --image-type "UBUNTU_CONTAINERD" \
    --node-labels="gke-no-default-nvidia-gpu-device-plugin=true" \
    --metadata disable-legacy-endpoints=true \
    --disk-size "100" \
    --num-nodes "1" \
    --tags=nvidia-ingress-all
```

Connect to the new cluster:
```bash
gcloud container clusters get-credentials $CLUSTER_NAME --region=$REGION
```

## Install GPU Operator

```bash
helm repo add nvidia https://helm.ngc.nvidia.com/nvidia
helm repo update
```

Find the latest versions
```bash
helm search repo nvidia/gpu-operator --versions 
helm show values nvidia/gpu-operator --version v24.9.1 | less
```

operator: https://github.com/NVIDIA/gpu-operator

docs: https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/index.html

```bash
export GPU_OPERATOR_VERSION=v24.9.1
kubectl create namespace gpu-operator
kubectl apply -f ./nim/gke-resourcequota.yaml
helm upgrade --install gpu-operator nvidia/gpu-operator --wait  \
    -n gpu-operator \
    --version=$GPU_OPERATOR_VERSION \
    -f ./nim/gpu-operator-values.yaml \
    --timeout 2m
```

### Verify

We should verify the device drivers were installed correctly and that the GPU nodes are correctly recognized.

Check all GPU operator pods are running
```bash
kubectl get pods -n gpu-operator
```

Debugging events
```bash
kubectl get events -n gpu-operator --sort-by='.lastTimestamp'
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

Get GPU Requests across Pods
```bash
kubectl get nodes "-o=custom-columns=NAME:.metadata.name,GPU:.status.allocatable.nvidia\.com/gpu,GPU_USED:.status.capacity.nvidia\.com/gpu"
```

Get GPU Requests across Pods
```bash
kubectl get pods -n default -o=jsonpath='{range .items[*]}{"Pod: "}{.metadata.name}{"\n"}{"CPU Requests: "}{.spec.containers[*].resources.requests.cpu}{"\n"}{"GPU Requests: "}{.spec.containers[*].resources.requests.nvidia\.com/gpu}{"\n"}{"Memory Requests: "}{.spec.containers[*].resources.requests.memory}{"\n\n"}{end}'
```


## Install NIM Operator
```bash
source ~/bin/ai-keys

helm repo add nvidia https://helm.ngc.nvidia.com/nvidia
helm repo update

helm search repo nvidia/k8s-nim-operator --versions
helm show values nvidia/k8s-nim-operator --version v1.0.1
```

Create the namespace
```bash
kubectl create namespace nvidia-nim
```

Create the secret
```bash
kubectl create secret docker-registry ngc-secret \
    --docker-server=nvcr.io \
    --docker-username='$oauthtoken' \
    --docker-password="$NGC_DOCKER_API_KEY" \
    --docker-email='christian.posta@solo.io' 

kubectl create secret generic ngc-api-secret \
    --from-literal=NGC_API_KEY="$NGC_API_KEY" 
```

Install the operator 

operator:
https://github.com/NVIDIA/k8s-nim-operator

docs:
https://docs.nvidia.com/nim-operator/latest/index.html

```bash
export NIM_OPERATOR_VERSION=v1.0.1
helm upgrade --install nim-operator nvidia/k8s-nim-operator --wait  \
    -n nvidia-nim \
    --version=$NIM_OPERATOR_VERSION \
    --set global.registry.secretName=ngc-secret
```

## Deploy NIM Cache

With this model cached: 
https://catalog.ngc.nvidia.com/orgs/nim/teams/meta/containers/llama-3.1-8b-instruct

Docker image:
https://build.nvidia.com/meta/llama-3_1-8b-instruct


```bash
kubectl apply -f ./nim/nimcache.yaml
```

## Deploy NIM Service
```bash
kubectl apply -f ./nim/nimservice.yaml
```

## Deploy Gateway
```bash
./install-gateway-nightly.sh $CONTEXT
```

Deploy NIM Upstream
```bash
kubectl apply -f ./nim/nim-upstream.yaml
kubectl apply -f ./nim/nim-httproute.yaml
```

Call the gateway:
```bash
TOKEN=$(cat ./resources/tokens/ceposta-openai.token)
call_gateway $TOKEN "meta/llama-3.1-8b-instruct" "v1/chat/completions"
```



## Scale down nodes
```bash
gcloud container clusters resize $CLUSTER_NAME \
    --zone $ZONE \
    --node-pool gpu-pool \
    --num-nodes 0 
```

```bash
gcloud container clusters resize $CLUSTER_NAME \
    --zone $ZONE \
    --node-pool default-pool \
    --num-nodes 0 
```


Put it back
```bash
gcloud container clusters resize $CLUSTER_NAME \
    --zone $ZONE \
    --node-pool gpu-pool \
    --num-nodes 1 
```

```bash
gcloud container clusters resize $CLUSTER_NAME \
    --zone $ZONE \
    --node-pool default-pool \
    --num-nodes 1 
```


Scale up
```bash
gcloud container clusters resize $CLUSTER_NAME \
    --zone $ZONE \
    --node-pool default-pool \
    --num-nodes 3
```

```bash
gcloud container clusters resize $CLUSTER_NAME \
    --zone $ZONE \
    --node-pool gpu-pool \
    --num-nodes 3
```

## Clean up
```bash
helm uninstall -n gpu-operator $(helm list -n gpu-operator -q)
kubectl delete namespace gpu-operator
```

```bash
gcloud container node-pools delete gpu-pool --cluster $CLUSTER_NAME --zone $ZONE
gcloud container clusters delete $CLUSTER_NAME --zone $ZONE
```


# Additional notes

Should consider using Local Path provisioner (from Rancher) if just doing things locally. 

https://github.com/rancher/local-path-provisioner

Enable Cloud filestore
https://console.developers.google.com/apis/api/file.googleapis.com/overview


Useful if going to use filestore
```bash
gcloud container clusters update $CLUSTER_NAME \
--update-addons=GcpFilestoreCsiDriver=ENABLED
```