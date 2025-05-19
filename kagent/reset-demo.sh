DIR=$(dirname ${BASH_SOURCE})
source env.sh

kubectl delete -f fetcher/deployment.yaml
kubectl delete -f agentgateway/deployment.yaml
kubectl delete toolservers -n kagent --all
kubectl delete memory -n kagent --all

# Delete all agents except the whitelisted ones
kubectl get agent -n kagent -o name | grep -v -E "argo-rollouts-conversion-agent|helm-agent|istio-agent|k8s-agent|observability-agent|promql-agent|kgateway-agent|cilium-crd-agent" | xargs -r kubectl delete -n kagent

# delete all model configs except t
kubectl get modelconfig -n kagent -o name | grep -v -E "default-model-config" | xargs -r kubectl delete -n kagent

# clean up any of the argo rollouts stuff i did
kubectl delete rollouts -n bookinfo-backends --all

./setup-bookinfo.sh 

kubectl delete authorizationpolicy -n bookinfo-backends --all
kubectl delete authorizationpolicy -n bookinfo-frontends --all
kubectl delete authorizationpolicy -n istio-ingress --all


kubectl label namespace bookinfo-backends istio.io/use-waypoint-
kubectl label namespace bookinfo-frontends istio.io/use-waypoint-





