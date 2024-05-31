/home/solo/scripted-solo-demos/ambient/scripts/setup-kind.sh

kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml

docker pull docker.io/slandow/some-demo-img
docker tag docker.io/slandow/some-demo-img:latest us-west2-docker.pkg.dev/octo-386314/gloo-waypoint/gloo-ee:latest
kind --name kind1 load docker-image us-west2-docker.pkg.dev/octo-386314/gloo-waypoint/gloo-ee:latest

# install Gloo Mesh
source ~/bin/gloo-mesh-license-env 
export GLOO_MESH_LICENSE_KEY=$GLOO_MESH_LICENSE

helm install -n gloo-system gloo --create-namespace ./gloo-ee-chart \
    --set gloo-fed.enabled=false \
    --set gloo.gatewayProxies.gatewayProxy.gatewaySettings.enabled=false \
    --set gloo-fed.glooFedApiserver.enable=false \
    --set gloo.kubeGateway.enabled=true \
    --set license_key="$GLOO_MESH_LICENSE_KEY"


istioctl install -y --set profile=ambient
istioctl version