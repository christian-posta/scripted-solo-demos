source env.sh

echo "Uninstall sample apps"
kubectl --context $1 delete ns istioinaction

echo "Uninstall gloo-mesh"
kubectl --context $1 delete ns gloo-mesh
kubectl --context $1 delete crd $(kubectl --context $1 get crd | grep mesh.gloo.solo.io) 

# get rid of any stale clusterrole/binding
kubectl --context $1 delete clusterrole $(kubectl --context $1 get enterprise-agent | grep wasm-agent | awk '{print $1}') 
kubectl --context $1 delete clusterrolebinding $(kubectl --context $1 get clusterrolebinding |  grep enterprise-agent | awk '{print $1}')

echo "Uninstall Istio..."
istioctl1.8 --context $1 x uninstall -y --purge
kubectl --context $1 delete ns istio-system

