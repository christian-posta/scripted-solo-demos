
GATEWAY_IP=$(kubectl get svc -n istio-system | grep ingressgateway | awk '{ print $4 }')

time for i in {1..100}; do kubectl exec -it deploy/sleep -- curl -H "Host: istioinaction.io" -s -o /dev/null --show-error http://$GATEWAY_IP/ ;  done


