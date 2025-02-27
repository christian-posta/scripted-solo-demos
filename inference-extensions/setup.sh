# Install garbage gateway
EG_VERSION=v1.2.1
kubectl apply --server-side -f https://github.com/envoyproxy/gateway/releases/download/$EG_VERSION/install.yaml
kubectl rollout status deployment envoy-gateway -n envoy-gateway-system



# set up the hF keys
source ~/bin/ai-keys
kubectl create secret generic hf-token --from-literal=token=$HF_TOKEN 

# deploy the actual models running on vllm
kubectl apply -f llm/deployment.yaml
kubectl rollout status deployment vllm-llama2-7b-pool



# deploy the inference extension for gateway api
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api-inference-extension/releases/download/v0.1.0/manifests.yaml

# create an inference model
kubectl apply -f inference/inferencemodel.yaml

# enable extensions in EG
kubectl apply -f eg/enable_patch_policy.yaml
kubectl rollout restart deployment envoy-gateway -n envoy-gateway-system


# deploy the gateway
kubectl apply -f inference/gateway.yaml

# deploy the endpoint picker ext_proc ext
kubectl apply -f inference/ext_proc.yaml

# deploy EG extension policies
kubectl apply -f eg/extension_policy.yaml
kubectl apply -f eg/patch_policy.yaml


