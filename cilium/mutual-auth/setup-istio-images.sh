
ISTIOCTL_LOCATION=/home/solo/dev/ambient
#VERSION=1.19.3-solo
VERSION=1.23.2-patch1-solo-distroless


source ~/bin/ambient-docker-repo

kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || \
  { kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd/experimental?ref=f98e94a5305e3a08cb14f8a03470f8f3bdf6d54c" | kubectl apply -f -; }


docker pull $REPO/pilot:$VERSION
docker tag $REPO/pilot:$VERSION gcr.io/istio-enterprise-private/pilot:$VERSION
kind load docker-image --name kind1 gcr.io/istio-enterprise-private/pilot:$VERSION

docker pull $REPO/solo-install-cni:$VERSION
docker tag $REPO/solo-install-cni:$VERSION gcr.io/istio-enterprise-private/solo-install-cni:$VERSION
kind load docker-image --name kind1 gcr.io/istio-enterprise-private/solo-install-cni:$VERSION

docker pull $REPO/install-cni:$VERSION
docker tag $REPO/install-cni:$VERSION gcr.io/istio-enterprise-private/install-cni:$VERSION
kind load docker-image --name kind1 gcr.io/istio-enterprise-private/install-cni:$VERSION


docker pull $REPO/ztunnel:$VERSION
docker tag $REPO/ztunnel:$VERSION gcr.io/istio-enterprise-private/ztunnel:$VERSION
kind load docker-image --name kind1 gcr.io/istio-enterprise-private/ztunnel:$VERSION


