source .env.sh

## Create cluster
####
From this documentation: https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/google-gke.html


### Create a cluster with CPU nodes and we'll add GPU nodes later
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

gcloud container node-pools create gpu-pool \
    --cluster $CLUSTER_NAME \
    --zone $ZONE \
    --machine-type "a2-highgpu-1g" \
    --image-type "UBUNTU_CONTAINERD" \
    --node-labels="gke-no-default-nvidia-gpu-device-plugin=true" \
    --disk-type "pd-standard" \
    --disk-size "100" \
    --metadata disable-legacy-endpoints=true \
    --num-nodes "1" \
    --tags=nvidia-ingress-all

gcloud container clusters get-credentials $CLUSTER_NAME --region=$REGION

## Install GPU Operator
helm repo add nvidia https://helm.ngc.nvidia.com/nvidia
helm repo update

### find the latest versions
helm search repo nvidia/gpu-operator --versions 
helm show values nvidia/gpu-operator --version v24.9.1 | less

export GPU_OPERATOR_VERSION=v24.9.1
kubectl create namespace gpu-operator
kubectl apply -f ./nim/gke-resourcequota.yaml
helm upgrade --install gpu-operator nvidia/gpu-operator --wait  \
    -n gpu-operator \
    --version=$GPU_OPERATOR_VERSION \
    -f ./nim/gpu-operator-values.yaml \
    --timeout 2m


### Verify

#### Check all GPU operator pods are running
kubectl get pods -n gpu-operator

#### Debugging events
kubectl get events -n gpu-operator --sort-by='.lastTimestamp'

#### Verify GPU nodes are properly recognized
kubectl get nodes "-o=custom-columns=NAME:.metadata.name,GPU:.status.allocatable.nvidia\.com/gpu"

#### Verify with nvidia-smi
POD=nvidia-driver-daemonset-vvj72
kubectl exec -it $POD -n gpu-operator -- nvidia-smi



## Install NIM Operator
source ~/bin/ai-keys

helm repo add nvidia https://helm.ngc.nvidia.com/nvidia
helm repo update

helm search repo nvidia/k8s-nim-operator --versions
helm show values nvidia/k8s-nim-operator --version v1.0.1

kubectl create namespace nvidia-nim

kubectl create secret docker-registry ngc-secret \
    --docker-server=nvcr.io \
    --docker-username='$oauthtoken' \
    --docker-password="$NGC_DOCKER_API_KEY" \
    --docker-email='christian.posta@solo.io' 

kubectl create secret generic ngc-api-secret \
    --from-literal=NGC_API_KEY="$NGC_API_KEY" 


export NIM_OPERATOR_VERSION=v1.0.1
helm upgrade --install nim-operator nvidia/k8s-nim-operator --wait  \
    -n nvidia-nim \
    --version=$NIM_OPERATOR_VERSION \
    --set global.registry.secretName=ngc-secret


## Deploy NIM Cache
kubectl apply -f ./nim/nimcache.yaml

## Deploy NIM Service
kubectl apply -f ./nim/nimservice.yaml



## Scale down nodes

gcloud container clusters resize $CLUSTER_NAME \
    --node-pool gpu-pool \
    --num-nodes 0 

gcloud container clusters resize $CLUSTER_NAME \
    --node-pool default-pool \
    --num-nodes 1 

##### Put it back
gcloud container clusters resize $CLUSTER_NAME \
    --node-pool gpu-pool \
    --num-nodes 1 

gcloud container clusters resize $CLUSTER_NAME \
    --node-pool default-pool \
    --num-nodes 3 



##################
## Clean up
##################
helm uninstall -n gpu-operator $(helm list -n gpu-operator -q)
kubectl delete namespace gpu-operator


gcloud container node-pools delete gpu-pool --cluster $CLUSTER_NAME --zone $ZONE
gcloud container clusters delete $CLUSTER_NAME --zone $ZONE


# Additional notes

## Enable Cloud filestore
https://console.developers.google.com/apis/api/file.googleapis.com/overview


#### useful if going to use filestore
gcloud container clusters update $CLUSTER_NAME \
--update-addons=GcpFilestoreCsiDriver=ENABLED