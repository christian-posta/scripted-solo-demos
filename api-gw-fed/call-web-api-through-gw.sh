export GATEWAY_IP=$(kubectl get gateway -n gloo-system | grep http | awk  '{ print $3 }')

curl -v -H "Host: web-api.solo.io" http://$GATEWAY_IP:8080/