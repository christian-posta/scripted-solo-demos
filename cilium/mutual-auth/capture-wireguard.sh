 SLEEP_ON_NODE=$(kubectl get pod -l app=sleep,version=v1 -o=jsonpath='{.items[0].spec.nodeName}')
 CILIUM_AGENT_POD=$(kubectl get po -n kube-system -o wide | grep 'cilium-[^o]' | grep $SLEEP_ON_NODE | awk '{ print $1 }')
 
 kubectl debug -it ${CILIUM_AGENT_POD} -n kube-system --image=nicolaka/netshoot --image-pull-policy=Always -- tshark -i eth0 -f "udp[8:1] >= 1 and udp[8:1] <= 4 and udp[9:1] == 0 and udp[10:2] == 0"