CONTEXT=${1:-ai-demo}

helm uninstall gloo-gateway -n gloo-system --kube-context $CONTEXT
kubectl --context $CONTEXT delete namespace gloo-system
kubectl --context $CONTEXT get crds | grep 'solo.io' | awk '{print $1}' | xargs kubectl --context $CONTEXT delete crd
