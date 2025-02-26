# This script will wipe out the GKE cluster for this demo

kubectl delete nimservice --all
kubectl delete httproute -n gloo-system nemoguard-8b-content-safety nim-llama3-1-8b   
kubectl delete routeoptions -n gloo-system nim-llama3-1-8b-options 


echo "Do you want to fully wipe the environment? All gateway/nim/monitoring stuff will be removed"
read -p "Are you sure? (y/n): " confirm
if [ "$confirm" != "y" ]; then
    echo "Exiting..."
    exit 1
fi

helm uninstall jaeger -n monitoring
helm uninstall kube-prometheus-stack -n monitoring
helm uninstall nim-operator -n nvidia-nim
helm uninstall opentelemetry-collector -n otel
helm uninstall gloo-gateway -n gloo-system