SLEEP_ON_NODE=$(kubectl get pod -l app=sleep,version=v1 -o=jsonpath='{.items[0].spec.nodeName}')
CILIUM_AGENT_POD=$(kubectl get po -n kube-system -o wide | grep 'cilium-[^o]' | grep $SLEEP_ON_NODE | awk '{ print $1 }')


kubectl exec -it $CILIUM_AGENT_POD -n kube-system bash
