# Set up services
. ~/bin/create-aws-secret
kubectl apply -f resources/k8s
kubectl apply -f resources/gloo

