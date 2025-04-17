kubectl delete cm agentproxy-config -n kagent
kubectl delete cm openapi-config -n kagent
kubectl delete cm pubkey-config -n kagent

kubectl create -n kagent configmap agentproxy-config --from-file=config.json=config.json
kubectl create -n kagent configmap openapi-config --from-file=petstore.json=petstore.json
kubectl create -n kagent configmap pubkey-config --from-file=pubkey=pubkey


kubectl rollout restart deployment agentproxy -n kagent
