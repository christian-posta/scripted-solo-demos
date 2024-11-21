
GATEWAY_IP=$(kubectl get svc -n istio-system | grep ingressgateway | awk '{ print $4 }')

curl -H "Host: istioinaction.io" http://$GATEWAY_IP/ 


