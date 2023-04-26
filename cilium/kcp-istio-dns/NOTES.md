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

Again, it should not work. NOW we should apply the CNI with hostNamespaceOnly


> ./reset-cni.sh
> ./01-upgrade-cilium.sh


Now if you go back to the sleep pod and curl for address.internal, you should see it resolve to the IP address listed in the service entry, although it won't eventually connect to anything. That's okay.
