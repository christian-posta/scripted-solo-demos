Notes to set up this demo.

run the following to bootstrap the cluster:

> ./setup-all.sh

Make sure you port forward the following services:

kiali 20001
kagent ui 8082
argo rollouts ui 3100
istio ingress /product page 8080


to update the image for the rollouts use the following command:

for v2
> kubectl set image deployment/reviews reviews=docker.io/istio/examples-bookinfo-reviews-v2:1.17.0 -n bookinfo-backends

for v3
> kubectl set image deployment/reviews reviews=docker.io/istio/examples-bookinfo-reviews-v3:1.17.0 -n bookinfo-backends


