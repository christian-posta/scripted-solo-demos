
# need local docker daemon to build images

# need access to docker push
docker login


# Need to set up Istio CRDs!
kubectl create ns istio-system
kubectl apply -f resources/init-istio.yaml
