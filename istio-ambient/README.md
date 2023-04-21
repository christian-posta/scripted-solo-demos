# Istio Ambient Mesh Demo


# With the public images:

source ./shell-profile.sh

istioctl install -d manifests/ --set hub=$HUB --set tag=$TAG -y --set profile=ambient

kubectl label namespace default istio.io/dataplane-mode=ambient

kubectl label namespace default istio.io/dataplane-mode-

istioctl uninstall -y --purge && kubectl delete ns istio-system


# Build

> tools/docker --targets=pilot,proxyv2,app,install-cni --hub=$HUB --tag=$TAG --push

# Install
> istioctl install -d manifests/ --set hub=$HUB --set tag=$TAG -y   --set profile=ambient --set meshConfig.accessLogFile=/dev/stdout --set meshConfig.defaultHttpRetryPolicy.attempts=0 --set values.global.imagePullPolicy=Always

> kubectl label namespace default istio.io/dataplane-mode=ambient

# Clean up

> kubectl label namespace default istio.io/dataplane-mode-
> istioctl x uninstall --purge
> k delete ns istio-system



