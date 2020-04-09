# Using Istio 1.4
# Create the secret for admiral to monitor
MANAGEMENT_CONTEXT=minikube
KUBECONFIG=/Users/ceposta/.kube/config


kubectl create -f resources/remotecluster.yaml
kubectl create -f resources/demosinglecluster.yaml

./resources/scripts/cluster-secret.sh $MANAGEMENT_CONTEXT $KUBECONFIG admiral