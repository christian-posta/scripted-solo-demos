
kubectl delete cm inference-dashboard
kubectl delete -f metrics/grafana.yaml
kubectl delete -f metrics/metrics-sa.yaml
helm uninstall my-prometheus

# Remove EG extension policies
kubectl delete -f eg/patch_policy.yaml
kubectl delete -f eg/extension_policy.yaml

# Remove the endpoint picker ext_proc ext
kubectl delete -f inference/ext_proc.yaml

# Remove the gateway
kubectl delete -f inference/gateway.yaml

# Disable extensions in EG
kubectl delete -f eg/enable_patch_policy.yaml
kubectl rollout restart deployment envoy-gateway -n envoy-gateway-system

# Delete the inference model
kubectl delete -f inference/inferencemodel.yaml

# Remove the inference extension for gateway api
kubectl delete -f https://github.com/kubernetes-sigs/gateway-api-inference-extension/releases/download/v0.1.0/manifests.yaml

# Delete the deployed models running on vllm
kubectl delete -f llm/gpu-deployment.yaml

# Remove the hF keys secret
kubectl delete secret hf-token

# Uninstall garbage gateway
EG_VERSION=v1.3.1
kubectl delete -f https://github.com/envoyproxy/gateway/releases/download/$EG_VERSION/install.yaml

kubectl delete -f load/llm-load-service.yaml