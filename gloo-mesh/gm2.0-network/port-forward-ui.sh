source ./env.sh
kubectl --context $MGMT port-forward svc/gloo-mesh-ui -n gloo-mesh 8090
