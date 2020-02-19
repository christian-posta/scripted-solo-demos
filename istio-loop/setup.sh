# install istio


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



kubectl apply -f resources/loop.yaml

kubectl create ns calc

# if doing auto injection:
kubectl label namespace calc istio-injection=enabled
kubectl apply -f resources/calc.yaml -n calc


# if doing manual injection:
# ~/dev/istio/istio-1.2.10/bin/istioctl kube-inject --injectConfigFile resources/custom-injection/inject-config-1.2.yaml --meshConfigFile resources/custom-injection/mesh-config-1.2.yaml --valuesFile resources/custom-injection/inject-values-1.2.yaml --filename resources/calc.yaml 

#~/dev/istio/istio-1.2.10/bin/istioctl kube-inject --injectConfigFile resources/custom-injection/inject-config-1.2.yaml --meshConfigFile resources/custom-injection/mesh-config-1.2.yaml --valuesFile resources/custom-injection/inject-values-1.2.yaml --filename resources/calc.yaml | kubectl apply -f -

kubectl apply -f resources/calc-gateway.yaml
INGRESS_IP=$(kubectl get svc -n istio-system | grep ingressgateway | head -n 1 | awk '{ print $4 }'
)

echo "Wait for ingress URL"
watch -- kubectl get svc -n istio-system

echo "Ingress URL: http://$INGRESS_IP"
