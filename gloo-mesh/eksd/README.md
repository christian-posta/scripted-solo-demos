docker run -d --rm --name ekz-controller \
   --hostname controller \
   --privileged -v /var/lib/ekz \
   -p 6443:6443 chanwit/ekz:v1.18.9-eks-1-18-1

https://github.com/chanwit/ekz

Also, should consider exposing a port on the docker container and specifying the NodePort on the istio ingress gateway service 

# cleanup container
docker kill ekz-controller  


# get config 
docker exec ekz-controller cat /var/lib/ekz/pki/admin.conf > /tmp/kubeconfig   
NOTE: need to rename the context to "kind-default"
export KUBECONFIG=/tmp/kubeconfig:~/.kube/config


# install Istio
export CLUSTER_1=Default
istioctl1.7 --context $CLUSTER_1 operator init
kubectl --context $CLUSTER_1 create ns istio-system
kubectl --context $CLUSTER_1 apply -f istio.yaml
