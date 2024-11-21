source env.sh

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
              port: 8080
            model: "meta/llama-3.1-8b-instruct"      
EOF