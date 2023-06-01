Steps to demo:

First set up the cluster 
> ./setup-kind.sh

Then Install the CNI and Istio / demo apps

> ./00-isntall-cni.sh
> ./20-prep-istio.sh

Verify that the sleep apps are deployed and there are sidecar proxies running with them.

Then, go to the sleep-v1 pod and try to curl for "address.internal"

> curl -v address.internal

it should NOT work

Then install the Istio service entry for address.internal:

> kubectl apply -f resources/dns-service-entry.yaml

Return to the sleep pod, and try to curl again.... 

> curl -v address.internal

Again, it should not work. 

If we want we can verify that Istio CP correctly picked up the service-entry:

> istioctl pc clusters deploy/sleep-v2 | grep address.internal

We can also confirm what hostnames are in the DNS proxy by querying the "name discovery service" in the control plane 

> PROXY_ID=$(istioctl proxy-status | grep sleep-v1 | awk '{print $1}')
> kubectl -n istio-system exec deploy/istiod -- curl -Ls "localhost:8080/debug/ndsz?proxyID=$PROXY_ID" | jq

We should see the "address.internal" hostname entry in there... this means Istio DEFINITELY should see the hostname in the DNS proxy and should be able to resolve it.... but it doesn't... so there's something fishy going on with the CNI. Let's investigate.




NOW we should apply the CNI with hostNamespaceOnly


> ./reset-cni.sh
> ./01-upgrade-cilium.sh


Now if you go back to the sleep pod and curl for address.internal, you should see it resolve to the IP address listed in the service entry, although it won't eventually connect to anything. That's okay.


### My notes

use this to copy a pcap file out of a debug ephemeral container in a pod after using termshark:

kubectl cp default/sleep-v1-54fc88fc49-cgb4n:/root/.cache/termshark/pcaps/cap1.pcap -c debugger-mmf9z  ./cap1.pcap


Port forward Hubble:

UI:
> kubectl port-forward -n kube-system svc/hubble-ui --address 0.0.0.0 --address :: 12000:80
or
> cilium hubble ui

Viewing it from desktop:

> ssh -L 12000:localhost:12000 -C -N -l solo cilium

Relay:
> kubectl port-forward -n kube-system svc/hubble-relay --address 0.0.0.0 --address :: 4245:80
or
> cilium hubble port-forward

Cluster-wide flows: 

> hubble observe -f --server localhost:4245

Per Agent (log in to the specific agent and run hubble observe, or cilium monitor)


Show ebpf chains on TC:

tc filter show dev lxc00aa ingress


## Need to install termshark?

First install go..

> apt install golang-go

Then install termshark
> apt install -y tshark
> go install github.com/gcla/termshark/v2/cmd/termshark@v2.4.0

## Using nsenter on kubernets
kubectl krew install nsenter