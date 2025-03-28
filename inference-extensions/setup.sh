# Set up the vllm models
# if you want to setup the llms, check out the setup-llms.sh script

./setup-kgateway.sh

# deploy the gateway
kubectl apply -f inference/gateway.yaml
kubectl wait --for=condition=Programmed gateway/inference-gateway --timeout=300s

# create an inference model
kubectl apply -f inference/inferencemodel.yaml
kubectl apply -f inference/inferencepool.yaml

# specify a route to the inferencepool
kubectl apply -f inference/httproute.yaml



helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install my-prometheus prometheus-community/prometheus

kubectl apply -f metrics/metrics-sa.yaml

TOKEN=$(kubectl -n default get secret inference-gateway-sa-metrics-reader-secret  -o jsonpath='{.secrets[0].name}' -o jsonpath='{.data.token}' | base64 --decode)
cat metrics/my-prometheus-server-cm.yaml | sed "s/<TOKEN>/${TOKEN}/g" | kubectl apply -f -

kubectl apply -f metrics/grafana.yaml

# now you have to manually import the dashboard into grafana
