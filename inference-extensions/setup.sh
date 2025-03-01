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


helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install my-prometheus prometheus-community/prometheus

kubectl apply -f metrics/metrics-sa.yaml

TOKEN=$(kubectl -n default get secret inference-gateway-sa-metrics-reader-secret  -o jsonpath='{.secrets[0].name}' -o jsonpath='{.data.token}' | base64 --decode)
cat metrics/my-prometheus-server-cm.yaml | sed "s/<TOKEN>/${TOKEN}/g" | kubectl apply -f -

kubectl apply -f metrics/grafana.yaml

kubectl  create cm inference-dashboard --from-file=./metrics/inference_gateway.json
kubectl label cm inference-dashboard grafana_dashboard=1