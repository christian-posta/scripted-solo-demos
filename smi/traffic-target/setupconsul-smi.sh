# before we install the smi controller, we need to create the appropriate ACLs
# Let's get the master key
BOOTSTRAP_TOKEN=$(kubectl get secret consul-consul-bootstrap-acl-token  -o jsonpath={.data.token} | base64 --decode)

echo "using master token $BOOTSTRAP_TOKEN"

kubectl port-forward statefulset/consul-consul-server 8500 & > /dev/null 2>&1
PF_PID=$!

echo "waiting for consul server to become available..."
while ! nc -z localhost 8500; do   
  echo "..."
  sleep 0.5 # wait for 1/10 of the second before check again
done

SMI_TOKEN=$(consul acl token create -description "read/write access for the consul-smi-controller" -policy-name global-management -token=$BOOTSTRAP_TOKEN | grep SecretID | awk '{ print $2}')

kill $PF_PID

echo "Using SMI Token $SMI_TOKEN"
kubectl create secret generic consul-smi-acl-token --from-literal=token=$TOKEN

# installing the consul-smi controller
kubectl create -f resources/consul-smi-controller.yaml