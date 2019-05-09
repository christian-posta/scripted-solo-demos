#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD

desc "Requires bookinfo installed"
read -s

if [ "$1" != "skip" ]; then 
    tmux split-window -v -d -c $SOURCE_DIR
    tmux select-pane -t 0
    tmux send-keys -t 1 "kubectl port-forward -n bookinfo-appmesh deploy/productpage-v1 9080" C-m

    
    desc "Opening product page"
    read -s
    run "open http://localhost:9080/productpage"
fi

desc "Let's add some traffic-control rules"
run "supergloo apply routingrule trafficshifting -i"

# ALso instead of interactive mode, could do one single command:
# name: split-reviews
# namespace: (can go anywhere) supergloo-system
# Source selectors (appmesh, specific, cannot use these): N
# desination selector: Y
# WHat kind of selector? Upstream
# Match destination of the catchall for reviews: supergloo-system.bookinfo-appmesh-reviews-9080
# request matcher? Y
# matcher type: prefix <<-- note, at least one matcher is necessary unfortunately (at the moment)
# leave emtpy the header matcher
# leave emtpy the HTTP method matcher
# on second prompt for another matcher say "N"
# target mesh: "supergloo-system.demo-appmesh"
#     how to split the traffic?
# Select reviews v1 (marco used supergloo-system.bookinfo-appmesh-reviews-9080 for this... idk)
# Select reviews v2
# Choose weight (ie, 50/50?)

# cli version:
# supergloo apply routingrule trafficshifting --name split-reviews --namespace supergloo-system --target-mesh supergloo-system.demo-appmesh --dest-upstreams supergloo-system.bookinfo-appmesh-reviews-9080 --request-matcher '{ "path_prefix":"/"}' --destination supergloo-system.bookinfo-appmesh-reviews-9080:1 --destination supergloo-system.bookinfo-appmesh-reviews-v2-9080:1

backtotop

desc "Lets take a look at the supergloo API for routing rules"
run "kubectl get routingrule split-reviews -n supergloo-system -o yaml"
backtotop

desc "Bring more traffic to v3"
run "supergloo apply routingrule trafficshifting --name split-reviews --namespace supergloo-system --target-mesh supergloo-system.demo-appmesh --dest-upstreams supergloo-system.bookinfo-appmesh-reviews-9080 --request-matcher '{ \"path_prefix\":\"/\"}' --destination supergloo-system.bookinfo-appmesh-reviews-9080:1 --destination supergloo-system.bookinfo-appmesh-reviews-v2-9080:1 --destination supergloo-system.bookinfo-appmesh-reviews-v3-9080:5"

backtotop

desc "Let's check the virtual routers in AWS"
run "aws appmesh list-virtual-routers --mesh-name demo-appmesh"

backtotop

desc "Show the route details in AWS app mesh"
run "aws appmesh describe-route --mesh-name demo-appmesh --virtual-router-name reviews-bookinfo-appmesh-svc-cluster-local --route-name reviews-bookinfo-appmesh-svc-cluster-local-0"
