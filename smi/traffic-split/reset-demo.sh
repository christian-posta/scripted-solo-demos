kubectl delete trafficsplits -n smi-demo --all
kubectl -n smi-demo delete virtualservices.networking.istio.io reviews-rollout-vs 
kubectl -n smi-demo apply -f resources/01-deploy-v1.yaml
kubectl -n smi-demo delete -f resources/03-deploy-v2.yaml