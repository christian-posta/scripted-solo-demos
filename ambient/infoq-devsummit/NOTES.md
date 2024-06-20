To get this demo working:

./setup-all.sh


# installing ambient mode
istioctl install -y -f ./resources/istio/install.yaml --set profile=ambient



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
kubectl apply -f ./resources/istio/ingress-web-api.yaml 

GATEWAY_IP=$(kubectl get svc -n istio-system | grep ingressgateway | awk '{ print $4 }')
curl -H "Host: istioinaction.io" http://$GATEWAY_IP/


# add routing to purchase history v1 only
kubectl apply -f ./resources/istio/purchase-history-v1-100.yaml

# allow for header based routing to purchase history v2 
kubectl apply -f ./resources/istio/purchase-history-header-v2.yaml

curl -H "x-test-routing: v2"  -H "Host: istioinaction.io" http://$GATEWAY_IP/


# Enabling tracing:
istioctl install -y -f ./resources/istio/tracing-install.yaml 

kubectl apply -f ./resources/istio/trace-sample-100.yaml 

# Enable routing to only v1
kubectl apply -f ./resources/istio/purchase-history-v1-100.yaml 

# enable policy

### deny all
kubectl apply -f ./resources/istio/peerauth-strict.yaml

kubectl apply -f ./resources/istio/policy/deny-all.yaml 

### try call will fail
curl -H "Host: istioinaction.io" http://$GATEWAY_IP/

### enable access to web-api
kubectl apply -f resources/istio/policy/allow-ingress-to-web-api.yaml 

### enable access to recommendation and purchase history
kubectl apply -f resources/istio/policy/allow-web-api-to-recommendation.yaml 


kubectl apply -f resources/istio/policy/allow-recommendation-to-purchistory.yaml 

##### need to do something different for waypoint in purchase history
kubectl apply -f resources/istio/policy/waypoint/allow-recommendation-to-purchistory.yaml 

### Now the curl through the GW should work
### The call from sleep should fail though
./call-web-api.sh 

# A more complex L7 policy


# Adding JWT Policy
kubectl apply -f resources/istio/policy/allow-web-api-with-jwt.yaml 
TOKEN=$(cat ./resources/istio/jwt/token.jwt)
curl -H "Authorization: Bearer $TOKEN" -H "Host: istioinaction.io" http://$GATEWAY_IP/

# adding the namespaces to istio-ambient
kubectl label namespace default istio.io/dataplane-mode=ambient
kubectl label namespace web-api istio.io/dataplane-mode=ambient
kubectl label namespace recommendation istio.io/dataplane-mode=ambient
kubectl label namespace purchase-history istio.io/dataplane-mode=ambient

# using waypoints
kubectl label ns web-api istio.io/use-waypoint=waypoint
kubectl label ns recommendation istio.io/use-waypoint=waypoint
kubectl label ns purchase-history istio.io/use-waypoint=waypoint

# delete waypoints
kubectl delete -f resources/istio/waypoint/web-api-ns.yaml
kubectl label ns web-api istio.io/use-waypoint-

kubectl delete -f resources/istio/waypoint/recommendation-ns.yaml
kubectl label ns recommendation istio.io/use-waypoint-

kubectl delete -f resources/istio/waypoint/purchase-history-ns.yaml
kubectl label ns purchase-history istio.io/use-waypoint-

# unlabel
kubectl label ns default istio.io/dataplane-mode-
kubectl label ns web-api istio.io/dataplane-mode-
kubectl label ns recommendation istio.io/dataplane-mode-
kubectl label ns purchase-history istio.io/dataplane-mode-






# Dashboards
http://localhost:3000

http://localhost:20001/kiali

http://localhost:16686/jaeger


If you want to install the latest Kiali:
https://kiali.io/docs/installation/quick-start/


helm install \
  --namespace istio-system \
  --set auth.strategy="anonymous" \
  --repo https://kiali.org/helm-charts \
  kiali-server \
  kiali-server