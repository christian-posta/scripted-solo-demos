
GATEWAY_IP=$(kubectl get svc -n istio-system | grep ingressgateway | awk '{ print $4 }')

TOKEN=$(cat ./resources/istio/jwt/token.jwt)
curl -H "Authorization: Bearer $TOKEN" -H "Host: istioinaction.io" http://$GATEWAY_IP/



