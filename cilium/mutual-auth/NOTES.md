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


SOURCE_DIR=$PWD
tmux split-window -v -d -c $SOURCE_DIR
tmux select-pane -t 0
tmux send-keys -t 1 C-l
tmux send-keys -t 1 "kubectl logs -n autoroute-operator -f $POD" C-m


tmux send-keys -t 1 C-c
tmux send-keys -t 1 "exit" C-m