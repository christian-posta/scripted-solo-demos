
DIR="/home/solo/dev/hack/ai-gateway-poc"

pushd $DIR
cd extproc_py
docker build -f Dockerfile . -t quay.io/solo-io/gloo-ai-extension
kind --name kind1 load docker-image quay.io/solo-io/gloo-ai-extension
kubectl apply -f deploy.yaml
cd ..


cd model_failover
docker build -f Dockerfile . -t quay.io/solo-io/model-failover
kind --name kind1 load docker-image quay.io/solo-io/model-failover
kubectl apply -f deploy.yaml
cd ..
popd