ns="default"
sleep_pod=$(kubectl get po -n $ns | grep sleep-v1 | awk '{print $1}')
httpbin_pod=$(kubectl get po -n $ns | grep httpbin | awk '{print $1}')

sleep_pod_node=$(kubectl get po -o wide -n default | grep $sleep_pod | awk '{print $7}')

httpbin_pod_node=$(kubectl get po -o wide -n default | grep $httpbin_pod | awk '{print $7}')


echo "Using sleep pod: $sleep_pod on node: $sleep_pod_node"
echo "Using httpbin pod: $httpbin_pod on node: $httpbin_pod_node"

### Get IP Addr from within pod:
sleep_ip_addr_str=$(kubectl debug -it $sleep_pod -n $ns --image=nicolaka/netshoot --image-pull-policy=Always -- ip addr | sed -n '/eth0/{N;N;p}')

httpbin_ip_addr_str=$(kubectl debug -it $httpbin_pod -n $ns --image=nicolaka/netshoot --image-pull-policy=Always -- ip addr | sed -n '/eth0/{N;N;p}')

sleep_vethpair_num=$(echo $sleep_ip_addr_str | awk {'print $2'} | cut -d '@' -f 2 | cut -d 'f' -f 2 )
sleep_mac_addr=$(echo $sleep_ip_addr_str | awk {'print $15'})
sleep_ip_addr=$(echo $sleep_ip_addr_str | awk {'print $21'})

httpbin_vethpair_num=$(echo $httpbin_ip_addr_str | awk {'print $2'} | cut -d '@' -f 2 | cut -d 'f' -f 2 )
httpbin_mac_addr=$(echo $httpbin_ip_addr_str | awk {'print $15'})
httpbin_ip_addr=$(echo $httpbin_ip_addr_str | awk {'print $21'})

echo "Sleep IP: $sleep_ip_addr MAC: $sleep_mac_addr VETH_PAIR: $sleep_vethpair_num"
echo "Sleep IP: $httpbin_ip_addr MAC: $httpbin_mac_addr VETH_PAIR: $httpbin_vethpair_num"


sleep_vethpair_str=$(docker exec -it $sleep_pod_node  ip addr | sed -n "/$sleep_vethpair_num/{N;p}")