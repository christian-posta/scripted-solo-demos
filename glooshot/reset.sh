killall kubectl
kubectl delete -f resources/experiment.yaml
kubectl delete -f resources/experiment-repeat.yaml
kubectl delete pod -l app=prometheus -n glooshot
kubectl apply -f resources/reviews-100-v4-unresilient.yaml