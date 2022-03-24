
source ./env.sh

kubectl config use-context ${MGMT}


## delete gloo edge
helm uninstall gloo-edge \
--namespace gloo-system --kube-context ${MGMT} 

kubectl --context ${MGMT} delete ns gloo-system 


helm uninstall gloo-mesh-enterprise \
--namespace gloo-mesh --kube-context ${MGMT} 

kubectl --context ${MGMT} delete ns gloo-mesh 
