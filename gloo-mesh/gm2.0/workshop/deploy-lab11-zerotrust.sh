#!/bin/bash

source ./env-workshop.sh

# comment out for now since we aren't going to use https
kubectl --context $CLUSTER1 apply -f lab11-workspace-isolation.yaml


# test it out

# pod=$(kubectl --context ${CLUSTER1} -n httpbin get pods -l app=in-mesh -o jsonpath='{.items[0].metadata.name}')
# kubectl --context ${CLUSTER1} -n httpbin debug -i ${pod} --image=curlimages/curl --image-pull-policy=Always -- curl -s -o /dev/null -w "%{http_code}" http://reviews.bookinfo-backends.svc.cluster.local:9080/reviews/0



