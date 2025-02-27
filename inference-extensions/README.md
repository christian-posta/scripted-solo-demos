### This temporarily uses Envoy Gateway for now. It's really hacky, and EG is garbage. As we are finding. 

```bash
EG_VERSION=v1.2.1
kubectl apply --server-side -f https://github.com/envoyproxy/gateway/releases/download/$EG_VERSION/install.yaml

kubectl apply -f enable_patch_policy.yaml
kubectl rollout restart deployment envoy-gateway -n envoy-gateway-system
```

### set up the hF keys
```bash
source ~/bin/ai-keys
kubectl create secret generic hf-token --from-literal=token=$HF_TOKEN 
```


### deploy the actual models running on vllm
```bash
kubectl apply -f llm/deployment.yaml
```

### deploy the inference extension for gateway api
```bash
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api-inference-extension/releases/download/v0.1.0/manifests.yaml
```

### create an inference model
```bash
kubectl apply -f inference/inferencemodel.yaml
```

### enable extensions in EG
```bash
kubectl apply -f eg/enable_patch_policy.yaml
kubectl rollout restart deployment envoy-gateway -n envoy-gateway-system
```


### deploy the gateway
```bash
kubectl apply -f inference/gateway.yaml
```

### deploy the endpoint picker ext_proc ext
```bash
kubectl apply -f inference/ext_proc.yaml
```

### deploy EG extension policies
```bash
kubectl apply -f eg/extension_policy.yaml
kubectl apply -f eg/patch_policy.yaml
```

### Call gateway
```bash
./call-gateway.sh
```

Should see a response like this:

```json
{
  "id": "cmpl-47f3d871-c429-4c2d-88b5-a99dbfd09a60",
  "object": "text_completion",
  "created": 1740669936,
  "model": "tweet-summary-0",
  "choices": [
    {
      "index": 0,
      "text": " Chronicle\n Write as if you were a human: San Francisco Chronicle\n\n 1. The article is about the newest technology that can help people to find their lost items.\n 2. The writer is trying to inform the readers that the newest technology can help them to find their lost items.\n 3. The writer is trying to inform the readers that the newest technology can help them to find their lost items.\n 4. The writer is trying to inform",
      "logprobs": null,
      "finish_reason": "length",
      "stop_reason": null,
      "prompt_logprobs": null
    }
  ],
  "usage": {
    "prompt_tokens": 11,
    "total_tokens": 111,
    "completion_tokens": 100,
    "prompt_tokens_details": null
  }
}
```


