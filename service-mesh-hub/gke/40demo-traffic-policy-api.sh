#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

SOURCE_DIR=$PWD
source env.sh


desc "Let's take a closer look at the Traffic Policy API"
desc "We'll look at matchers, fault injection, and retries across clusters"
desc "Now let's take a look at access control"
read -s


exit


kubectl apply -f resources/traffic-policy-fault.yaml
kubectl apply -f resources/traffic-policy-details.yaml

meshctl describe service reviews.default.cluster-1
meshctl describe service details.default.cluster-1