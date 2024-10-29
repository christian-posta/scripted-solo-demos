ITERATIONS=${1:-250}

GATEWAY_IP=$(kubectl get svc -n istio-system | grep ingressgateway | awk '{ print $4 }')

time for i in $( eval echo {0..$ITERATIONS} ); do curl -H "Host: istioinaction.io" -s -o /dev/null --show-error http://$GATEWAY_IP/ ;  done


