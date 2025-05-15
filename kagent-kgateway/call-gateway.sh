export INGRESS_GW_ADDRESS=$(kubectl get svc -n kgateway-system ai-gateway -o jsonpath="{.status.loadBalancer.ingress[0]['hostname','ip']}")
echo $INGRESS_GW_ADDRESS  


curl -s "$INGRESS_GW_ADDRESS:8080/openai" -H content-type:application/json  -d '{
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