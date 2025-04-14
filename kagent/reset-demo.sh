DIR=$(dirname ${BASH_SOURCE})
source env.sh

kubectl delete -f fetcher/deployment.yaml
kubectl delete -f resources/agents/fetcher-agent.yaml
kubectl delete -f resources/agents/fetcher-toolserver.yaml

# clean up any of the argo rollouts stuff i did
kubectl delete rollouts -n bookinfo-backends --all

./setup-bookinfo.sh 

kubectl delete authorizationpolicy -n bookinfo-backends --all
kubectl delete authorizationpolicy -n bookinfo-frontends --all
kubectl delete authorizationpolicy -n istio-ingress --all


kubectl label namespace bookinfo-backends istio.io/use-waypoint-
kubectl label namespace bookinfo-frontends istio.io/use-waypoint-


