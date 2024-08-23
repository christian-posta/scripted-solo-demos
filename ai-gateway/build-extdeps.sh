
DIR="/home/solo/dev/hack/ai-gateway-poc"

pushd $DIR
cd extproc_py
docker build -f Dockerfile . -t quay.io/solo-io/gloo-ai-extension
kind --name kind1 load docker-image quay.io/solo-io/gloo-ai-extension
cd ..


cd model_failover
docker build -f Dockerfile . -t quay.io/solo-io/model-failover
kind --name kind1 load docker-image quay.io/solo-io/model-failover
cd ..

cd samples/postgres-rag
docker build -f Dockerfile . -t quay.io/solo-io/vector-db
kind --name kind1 load docker-image quay.io/solo-io/vector-db
popd