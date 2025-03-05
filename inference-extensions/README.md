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

# Set up metrics

infer ext: https://gateway-api-inference-extension.sigs.k8s.io/guides/metrics/
vLLM: https://docs.vllm.ai/en/latest/serving/metrics.html

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install my-prometheus prometheus-community/prometheus
```

then you gotta manually edit the 
scrape_interval (5s) and evaluation_interval (30s)
for the my-prometheus-server configmap
and also add the job names:



Use the following token for the token part:

```bash
k apply -f ./metrics/metrics-sa.yaml 
TOKEN=$(kubectl -n default get secret inference-gateway-sa-metrics-reader-secret  -o jsonpath='{.secrets[0].name}' -o jsonpath='{.data.token}' | base64 --decode)
```

Can check the metrics are reachable from within the sleep container like this:

```bash
curl -s -H "Authorization: Bearer $TOKEN" inference-gateway-ext-proc:9090/metrics 
```

k get cm/my-prometheus-server -o yaml

```yaml
    global:
      scrape_interval: 5s
      evaluation_interval: 30s
    rule_files:
    - /etc/config/recording_rules.yml
    - /etc/config/alerting_rules.yml
    - /etc/config/rules
    - /etc/config/alerts
    scrape_configs:
    # Envoy metrics not tested yet
    #- job_name: envoy
    #  scheme: http
    #  metrics_path: /stats/prometheus
    #  static_configs:
    #  - targets:
    #    - 'envoy.default.svc:19001'
    - job_name: vllm
      scheme: http
      metrics_path: /metrics
      static_configs:
      - targets:
        - 'vllm-llama2-7b-pool.default.svc:8000'
    - job_name: 'inference-extension'
      scheme: http
      metrics_path: /metrics
      authorization:
        credentials: "<CREDS_FROM_INFER_EXT_METRICS_DOCS>"
      static_configs:
      - targets:
          - 'inference-gateway-ext-proc.default.svc:9090'
```


Expose the metrics port on the service

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: inference-gateway-ext-proc
  namespace: default
spec:
  selector:
    app: inference-gateway-ext-proc
  ports:
    - name: grpc
      protocol: TCP
      port: 9002
      targetPort: 9002
    - name: metrics
      protocol: TCP
      port: 9090
      targetPort: 9090
  type: ClusterIP
EOF
```

Grafana

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: grafana-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: grafana
  name: grafana
spec:
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      securityContext:
        fsGroup: 472
        supplementalGroups:
          - 0
      containers:
        - name: grafana
          image: grafana/grafana:latest
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 3000
              name: http-grafana
              protocol: TCP
          readinessProbe:
            failureThreshold: 3
            httpGet:
              path: /robots.txt
              port: 3000
              scheme: HTTP
            initialDelaySeconds: 10
            periodSeconds: 30
            successThreshold: 1
            timeoutSeconds: 2
          livenessProbe:
            failureThreshold: 3
            initialDelaySeconds: 30
            periodSeconds: 10
            successThreshold: 1
            tcpSocket:
              port: 3000
            timeoutSeconds: 1
          resources:
            requests:
              cpu: 250m
              memory: 750Mi
          volumeMounts:
            - mountPath: /var/lib/grafana
              name: grafana-pv
      volumes:
        - name: grafana-pv
          persistentVolumeClaim:
            claimName: grafana-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: grafana
spec:
  ports:
    - port: 3000
      protocol: TCP
      targetPort: http-grafana
  selector:
    app: grafana
  sessionAffinity: None
EOF
```

Now port-forward the grafana dashboard and import the `./metrics/inference-gateway.json` dashboard file. 

When you run load (ie, `./call-gateway.sh load` ) you should start to see metrics in all of the panels. 

If you need to debug, check that the prometheus scraping is working by port-forward the prometheus server (:9090) and check `localhost:9090/targets`. If that looks good, then check the metrics that are getting scraped in the `localhost:9090/query`

# API Load Testing Tool

This tool allows you to perform load testing against an OpenAI-compatible API endpoint by sending concurrent requests.

## Prerequisites

- Python 3.7+
- kubectl configured to access your Kubernetes cluster with the inference-gateway
- Required Python packages (install using `pip install -r requirements.txt`)

## Installation

1. Clone this repository or download the files
2. Install the required dependencies:

```bash
pip install -r requirements.txt
```

## Usage

Run the load test with default parameters:

```bash
python load_test.py
```

Run with specific params

```bash
python load_test.py --requests 100 --vary-prompts
```

Or a specific gateway:

```bash
python load_test.py --requests 100 --vary-prompts --gateway-url http://IPHERE:8000 
```

### Command Line Arguments

- `--concurrency`: Number of concurrent requests (default: 10)
- `--requests`: Total number of requests to make (default: 25)
- `--model`: Model to use for completions (default: "tweet-summary")
- `--prompt`: Prompt to send to the API (default: "Write as if you were a critic: San Francisco")
- `--max-tokens`: Maximum number of tokens to generate (default: 100)
- `--temperature`: Temperature for sampling (default: 0)
- `--vary-prompts`: If a prompt is not specified, then generate some automatically
- `--gateway-url`: The specific gateway url to call, defaults to figuring out automatically
- `--ramp-up-time`: Time in seconds to gradually ramp up to full concurrency (default: 0)
- `--ramp-up-pattern`: Pattern for ramping up concurrency. Options are `linear`, `exponential`, or `step` (default: `linear`).


### Examples

Run 50 requests with 20 concurrent connections:
(recommended to use ramp-up time to not slam the backends right off the bat)

```bash
python load_test.py --concurrency 100 --requests 500 --ramp-up-time 30
```

Use a different model and prompt:

```bash
python load_test.py --model "different-model" --prompt "Describe the weather in New York"
```

## Output

The script will output:
- Total time taken for all requests
- Number of successful and failed requests
- Average, minimum, and maximum response times
- Requests per second

## Notes

- The script automatically retrieves the gateway IP from your Kubernetes cluster
- Ensure your kubectl context is set correctly before running the script