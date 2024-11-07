## Setting up NIM

https://cloud.google.com/blog/products/containers-kubernetes/nvidia-nims-are-available-on-gke

Alternative, using helm:
https://github.com/NVIDIA/nim-deploy/tree/main/cloud-service-providers/google-cloud/gke


Connect the gke clusters to local machine:

gcloud container clusters get-credentials $CLUSTER --region $REGION --project $PROJECT

Also: note you have to enable firewall to allow traffic from the cluster1 to the ingress IP of cluster 2

export INGRESS_GW_ADDRESS2=$(kubectl --context $CLUSTER2 get svc -n gloo-system gloo-proxy-ai-gateway -o jsonpath="{.status.loadBalancer.ingress[0]['hostname','ip']}")

gcloud compute firewall-rules create allow-egress-to-public-ip \
    --direction=EGRESS \
    --priority=1000 \
    --network=ceposta-nim-on-gke-vpc-43b8822d \
    --action=ALLOW \
    --rules=tcp:8000 \
    --destination-ranges=$INGRESS_GW_ADDRESS2 \
    --target-tags=<your-cluster-network-tags>

## Set up the AI Gateway

./setup-all.sh
./reset-demo.sh


## Test commands
Test out the openai endpoint:

export INGRESS_GW_ADDRESS1=$(kubectl --context $CLUSTER1 get svc -n gloo-system gloo-proxy-ai-gateway -o jsonpath="{.status.loadBalancer.ingress[0]['hostname','ip']}")

export INGRESS_GW_ADDRESS2=$(kubectl --context $CLUSTER2 get svc -n gloo-system gloo-proxy-ai-gateway -o jsonpath="{.status.loadBalancer.ingress[0]['hostname','ip']}")

echo "AI Gateway (Cluster 1) endpoint INGRESS_GW_ADDRESS1: $INGRESS_GW_ADDRESS1"
echo "AI Gateway (Cluster 2) endpoint INGRESS_GW_ADDRESS2: $INGRESS_GW_ADDRESS2"

### calling cluster 1
curl "$INGRESS_GW_ADDRESS1:8080/openai" -H content-type:application/json  -d '{
  "model": "gpt-3.5-turbo",
  "messages": [
    {
      "role": "system",
      "content": "You are a poetic assistant, skilled in explaining complex programming concepts with creative flair."
    },
    {
      "role": "user",
      "content": "Compose a poem that explains the concept of recursion in programming."
    }
  ]
}' | jq



Test out the NIM endpoint:

curl -X 'POST' \
    "$INGRESS_GW_ADDRESS1:8080/nim" \
    -H 'accept: application/json' \
    -H 'Content-Type: application/json' \
    -d '{
  "messages": [
    {
      "content": "You are a polite and respectful chatbot helping people plan a vacation.",
      "role": "system"
    },
    {
      "content": "What should I do for a 4 day vacation in Spain?",
      "role": "user"
    }
  ],
  "model": "meta/llama-3.1-8b-instruct",
  "max_tokens": 4096,
  "top_p": 1,
  "n": 1,
  "stream": false,
  "stop": "\n",
  "frequency_penalty": 0.0
}' | jq



Count model invocations:

for i in {1..10}; do 
  curl "$INGRESS_GW_ADDRESS1:8080/openai" -H content-type:application/json  -d '{
  "model": "gpt-3.5-turbo",
  "messages": [
    {
      "role": "system",
      "content": "You are a poetic assistant, skilled in explaining complex programming concepts with creative flair."
    },
    {
      "role": "user",
      "content": "Compose a poem that explains the concept of recursion in programming."
    }
  ]
}' | jq -r '.model'
done | sort | uniq -c | awk '/meta\/llama-3.1-8b-instruct/ {llama_count=$1} /gpt-3.5-turbo-0125/ {gpt_count=$1} END {print "meta/llama-3.1-8b-instruct:", llama_count ? llama_count : 0; print "gpt-3.5-turbo-0125:", gpt_count ? gpt_count : 0}'


## Experimental Failover

export INGRESS_GW_ADDRESS2=$(kubectl --context $CLUSTER2 get svc -n gloo-system gloo-proxy-ai-gateway -o jsonpath="{.status.loadBalancer.ingress[0]['hostname','ip']}")

kubectl apply --context ${CLUSTER1} -f - <<EOF
apiVersion: gloo.solo.io/v1
kind: Upstream
metadata:
  labels:
    app: gloo
  name: nim-llama3-1-8b
  namespace: gloo-system
spec:
  connectionConfig:
    connectTimeout: '30s'
  ai:
    multi:
      priorities:
      - pool:
        - openai:
            customHost:
              host: my-nim-nim-llm.nim.svc.cluster.local
              port: 8000
            model: "meta/llama-3.1-8b-instruct"                
      - pool:
        - openai:
            customHost:
              host: $INGRESS_GW_ADDRESS2
              port: 8000
            model: "meta/llama-3.1-8b-instruct"      
EOF



## Set up Istio ambient to get mTLS
kubectl --context $CLUSTER1 apply -f resources/gke-resource-quota.yaml 
istioctl --context $CLUSTER1 install -y --set profile=ambient
kubectl --context $CLUSTER1 apply -f ~/dev/istio/latest/samples/addons/
kubectl --context $CLUSTER1 label namespace gloo-system istio.io/dataplane-mode=ambient
kubectl --context $CLUSTER1 label namespace nim istio.io/dataplane-mode=ambient


kubectl --context $CLUSTER2 apply -f resources/gke-resource-quota.yaml 
istioctl --context $CLUSTER2 install -y --set profile=ambient
kubectl --context $CLUSTER2 apply -f ~/dev/istio/latest/samples/addons/
kubectl --context $CLUSTER2 label namespace gloo-system istio.io/dataplane-mode=ambient
kubectl --context $CLUSTER2 label namespace nim istio.io/dataplane-mode=ambient