To get this demo working:

./setup-all.sh



# adding the namespaces to istio sidecar injection
kubectl label namespace default istio-injection=enabled --overwrite
kubectl label namespace web-api istio-injection=enabled --overwrite
kubectl label namespace recommendation istio-injection=enabled --overwrite
kubectl label namespace purchase-history istio-injection=enabled --overwrite

kubectl rollout restart deploy/sleep -n default
kubectl rollout restart deployment --selector=prod=stable -n web-api
kubectl rollout restart deployment --selector=prod=stable -n recommendation
kubectl rollout restart deployment --selector=prod=stable -n purchase-history

# remove sidecar injection

kubectl label ns default istio-injection-
kubectl label ns web-api istio-injection-
kubectl label ns recommendation istio-injection-
kubectl label ns purchase-history istio-injection-


kubectl rollout restart deploy/sleep -n default
kubectl rollout restart deployment --selector=prod=stable -n web-api
kubectl rollout restart deployment --selector=prod=stable -n recommendation
kubectl rollout restart deployment --selector=prod=stable -n purchase-history


# add an ingress 
kubectl apply -f ./istio/ingress-web-api.yaml 

GATEWAY_IP=$(kubectl get svc -n istio-system | grep ingressgateway | awk '{ print $4 }')
curl -H "Host: istioinaction.io" http://$GATEWAY_IP/

# Enabling tracing:
istioctl install -y -f ./istio/tracing-install.yaml 
kubectl apply -f istio/trace-sample-100.yaml 

# Enable routing to only v1
kubectl apply -f resources/istio/purchase-history-v1-100.yaml 

# enable policy

### deny all
kubectl apply -f resources/istio/peerauth-strict.yaml
kubectl apply -f resources/istio/policy/deny-all.yaml 

### try call will fail
curl -H "Host: istioinaction.io" http://$GATEWAY_IP/

### enable access to web-api
kubectl apply -f resources/istio/policy/allow-ingress-to-web-api.yaml 

### enable access to recommendation and purchase history
kubectl apply -f resources/istio/policy/allow-web-api-to-recommendation.yaml 
kubectl apply -f resources/istio/policy/allow-recommendation-to-purchistory.yaml 

### Now the curl through the GW should work
### The call from sleep should fail though
./call-web-api.sh 

# A more complex L7 policy


# adding the namespaces to istio-ambient
kubectl label namespace default istio.io/dataplane-mode=ambient
kubectl label namespace web-api istio.io/dataplane-mode=ambient
kubectl label namespace recommendation istio.io/dataplane-mode=ambient
kubectl label namespace purchase-history istio.io/dataplane-mode=ambient

# unlabel
kubectl label ns default istio.io/dataplane-mode-
kubectl label ns web-api istio.io/dataplane-mode-
kubectl label ns recommendation istio.io/dataplane-mode-
kubectl label ns purchase-history istio.io/dataplane-mode-












# call client
kubectl exec -it deploy/sleep -- sh

kubectl exec -it deploy/sleep -- curl -v http://web-api.web-api:8080/

# call through gateway
export GATEWAY_IP=$(kubectl get gateway -n gloo-system | grep http | awk  '{ print $3 }')

curl -v -H "Host: web-api.solo.io" http://$GATEWAY_IP:8080/

curl -v -H "Authorization: Bearer $JWT" -H "Host: web-api.solo.io" http://$GATEWAY_IP:8080/

# call with JWT
kubectl apply -f resources/extensions/httproute-web-api-jwt.yaml
source ./jwt.sh 

curl -v -H "Authorization: Bearer $JWT" -H "Host: web-api.solo.io" http://$GATEWAY_IP:8080/

kubectl exec -it deploy/sleep -- curl -H "Authorization: Bearer $JWT" -v http://web-api.web-api:8080/

# get traffic to go through the waypoint on web-api
kubectl label service web-api -n web-api istio.io/use-waypoint=web-api-gloo-waypoint
kubectl label service recommendation -n recommendation istio.io/use-waypoint=recommendation-gloo-waypoint
kubectl label service purchase-history -n purchase-history istio.io/use-waypoint=purchase-history-gloo-waypoint
