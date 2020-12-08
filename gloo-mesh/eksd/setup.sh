docker run -d --rm --name ekz-controller \
   --hostname controller \
   --privileged -v /var/lib/ekz \
   -p 6443:6443 chanwit/ekz:v1.18.9-eks-1-18-1

echo "Waiting for kube"
sleep 10s

docker exec ekz-controller cat /var/lib/ekz/pki/admin.conf > /tmp/kubeconfig   
export KUBECONFIG=/tmp/kubeconfig:~/.kube/config
