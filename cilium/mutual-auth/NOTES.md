Steps to demo:

Note, we need to forward hubble UI:

> cilium hubble ui```

and then on the Laptop run 

> ./ssh-port-forward.sh


# read bpf maps for auth
> cilium bpf auth list


# Show TLS connections using tshark
> tshark -i eth0 -Y 'ssl.handshake'

# eg follow the tls connections performed by an agent:
SLEEP_ON_NODE=$(kubectl get pod -l app=sleep,version=v1 -o=jsonpath='{.items[0].spec.nodeName}')
CILIUM_AGENT_POD=$(k get po -n kube-system -o wide | grep cilium | grep $SLEEP_ON_NODE | awk '{ print $1 }')
kubectl debug -it ${CILIUM_AGENT_POD} -n kube-system --image=nicolaka/netshoot --image-pull-policy=Always -- tshark -i eth0 -Y 'ssl.handshake'



Steps to demo:

* Set up kind cluters 
* ./setup-kind.sh
* ./setup-istio-images.sh
* ./00-isntall-cni.sh
* ./10-install-sample-apps.sh
* ./demo.sh
* ./demo-wrong-identity.sh


If you want to show Istio defense in depth:

* ./15-reset-test.sh
* ./20-install-istio-ambient.sh
* ./25-configure-istio-authz.sh
* ./call-combinations.sh
* ./demo-wrong-identity.sh