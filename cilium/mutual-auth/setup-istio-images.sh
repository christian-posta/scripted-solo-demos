
ISTIOCTL_LOCATION=/home/solo/dev/ambient



source ~/bin/ambient-docker-repo

kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || \
  { kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd/experimental?ref=f98e94a5305e3a08cb14f8a03470f8f3bdf6d54c" | kubectl apply -f -; }


docker pull $REPO/pilot:1.19.0-rc.0-patch2
docker tag $REPO/pilot:1.19.0-rc.0-patch2 gcr.io/istio-enterprise-private/pilot:1.19.0-rc.0-patch2
kind load docker-image --name kind1 gcr.io/istio-enterprise-private/pilot:1.19.0-rc.0-patch2

docker pull $REPO/solo-install-cni:1.19.0-rc.0-patch2
docker tag $REPO/solo-install-cni:1.19.0-rc.0-patch2 gcr.io/istio-enterprise-private/solo-install-cni:1.19.0-rc.0-patch2
kind load docker-image --name kind1 gcr.io/istio-enterprise-private/solo-install-cni:1.19.0-rc.0-patch2

docker pull $REPO/install-cni:1.19.0-rc.0-patch2
docker tag $REPO/install-cni:1.19.0-rc.0-patch2 gcr.io/istio-enterprise-private/install-cni:1.19.0-rc.0-patch2
kind load docker-image --name kind1 gcr.io/istio-enterprise-private/install-cni:1.19.0-rc.0-patch2


docker pull $REPO/ztunnel:1.19.0-rc.0-patch2
docker tag $REPO/ztunnel:1.19.0-rc.0-patch2 gcr.io/istio-enterprise-private/ztunnel:1.19.0-rc.0-patch2
kind load docker-image --name kind1 gcr.io/istio-enterprise-private/ztunnel:1.19.0-rc.0-patch2


