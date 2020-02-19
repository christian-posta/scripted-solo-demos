glooshot register
glooshot init

## Need to install istio here
function wait_for {
  DONE=false
  while ! $DONE; do
      echo "Waiting for Istio $1"
      sleep 3
      RUNNING=$(kubectl get pod -n istio-system | grep $1 | head -n 1 | awk '{ print $3 }')
      if [ $RUNNING == "Running" ]; then
          DONE=true
      fi
  done
}

kubectl apply -f resources/istio-1.0.yaml
wait_for "pilot"
wait_for "injector"


## I guess we can use supergloo to bridge the prometheus
supergloo set mesh stats \
    --target-mesh glooshot.istio-istio-system \
    --prometheus-configmap glooshot.glooshot-prometheus-server    


kubectl create ns bookinfo
kubectl label namespace bookinfo istio-injection=enabled
kubectl apply -n bookinfo -f resources/bookinfo.yaml    

kubectl apply -f resources/bookinfo-gateway.yaml
kubectl apply -f resources/reviews-100-v4-unresilient.yaml

INGRESS_IP=$(kubectl get svc -n istio-system | grep ingressgateway | head -n 1 | awk '{ print $4 }'
)

echo "Wait for ingress URL"
watch -- kubectl get svc -n istio-system

echo "Ingress URL: http://$INGRESS_IP"    