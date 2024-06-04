./setup-kind.sh

docker pull docker.io/slandow/some-demo-img
docker tag docker.io/slandow/some-demo-img:latest us-west2-docker.pkg.dev/octo-386314/gloo-waypoint/gloo-ee:latest
kind --name kind1 load docker-image us-west2-docker.pkg.dev/octo-386314/gloo-waypoint/gloo-ee:latest

kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml


source ~/bin/gloo-mesh-license-env 
export GLOO_MESH_LICENSE_KEY=$GLOO_MESH_LICENSE

helm install -n gloo-system gloo --create-namespace ./waypoint-demo/gloo-ee-chart \
    --set gloo-fed.enabled=false \
    --set gloo-fed.glooFedApiserver.enable=false \
    --set gloo.kubeGateway.enabled=true \
    --set gloo.gloo.disableLeaderElection=true \
    --set gloo.discovery.enabled=false \
    --set license_key="$GLOO_MESH_LICENSE_KEY"

kubectl delete deploy,service gateway-proxy -n gloo-system

kubectl apply -f sample-apps/

