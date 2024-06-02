/home/solo/scripted-solo-demos/ambient/scripts/setup-kind.sh

kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml


kubectl apply -f sample-apps/

docker pull docker.io/slandow/some-demo-img
docker tag docker.io/slandow/some-demo-img:latest us-west2-docker.pkg.dev/octo-386314/gloo-waypoint/gloo-ee:latest
kind --name kind1 load docker-image us-west2-docker.pkg.dev/octo-386314/gloo-waypoint/gloo-ee:latest

# can get the CLI
curl -sL https://run.solo.io/gloo/install | sh

# install Gloo Gateway
source ~/bin/gloo-mesh-license-env 
export GLOO_MESH_LICENSE_KEY=$GLOO_MESH_LICENSE

helm install -n gloo-system gloo --create-namespace ./gloo-ee-chart \
    --set gloo-fed.enabled=false \
    --set gloo-fed.glooFedApiserver.enable=false \
    --set gloo.kubeGateway.enabled=true \
    --set gloo.gloo.disableLeaderElection=true \
    --set gloo.discovery.enabled=false \
# for some reason, these are not taking affect
#    --set gatewayProxies.gatewayProxy.disable=true \
#    --set gatewayProxies.gatewayProxy.kind.deployment.replicas=0 \
#    --set gatewayProxies.gatewayProxy.service.type=clusterIP \
    --set license_key="$GLOO_MESH_LICENSE_KEY"

# We should delete the gateway-proxy stuff out of the box for the demo
kubectl delete deploy,service gateway-proxy -n gloo-system

istioctl install -y --set profile=ambient
istioctl version


kubectl label namespace web-api istio.io/dataplane-mode=ambient
kubectl label namespace recommendation istio.io/dataplane-mode=ambient
kubectl label namespace purchase-history istio.io/dataplane-mode=ambient

# unlabel
kubectl label ns web-api istio.io/dataplane-mode-

# call client
kubectl exec -it deploy/sleep -- sh

kubectl exec -it deploy/sleep -- curl http://web-api.web-api:8080

# call through gateway
export GATEWAY_IP=$(kubectl get gateway -n gloo-system | grep http | awk  '{ print $3 }')

curl -v -H "Host: web-api.solo.io" http://$GATEWAY_IP:8080/

# call with JWT
kubectl apply -f resources/extensions/httproute-web-api-jwt.yaml
source ./waypoint/jwt.sh 
curl -v -H "Authorization: Bearer $JWT" -H "Host: web-api.solo.io" http://$GATEWAY_IP:8080/
