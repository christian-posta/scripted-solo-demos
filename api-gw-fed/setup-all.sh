./setup-kind.sh

kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml


source ~/bin/gloo-gateway-license
export GLOO_LICENSE_KEY=$GLOO_LICENSE

## Install Istio CRDs ahead of time for Gloo, since we are going to use waypoints
kubectl apply -f /home/solo/dev/istio/istio-1.23.0/manifests/charts/base/crds

helm repo add gloo-ee-test https://storage.googleapis.com/gloo-ee-test-helm
helm repo update

helm install -f ./values.yaml -n gloo-system gloo-ee-test gloo-ee-test/gloo-ee \
    --create-namespace \
    --version 1.18.0-beta1-bmain-cd58f97 \
    --set license_key="$GLOO_LICENSE_KEY"



kubectl delete deploy,service gateway-proxy -n gloo-system

kubectl apply -f sample-apps/

