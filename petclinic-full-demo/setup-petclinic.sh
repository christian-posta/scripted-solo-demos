. ~/bin/create-aws-secret
kubectl apply -f petclinic.yaml
kubectl apply -f default-vs-1.0.yaml
kubectl get pod -w
