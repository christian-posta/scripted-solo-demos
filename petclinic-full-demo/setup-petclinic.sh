. ~/bin/create-aws-secret
kubectl apply -f petclinic.yaml
kubectl apply -f default-vs.yaml
kubectl get pod -w
