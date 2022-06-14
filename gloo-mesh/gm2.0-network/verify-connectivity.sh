#!/bin/bash
source env.sh

pod=$(kubectl --context ${MGMT_CONTEXT} -n gloo-mesh get pods -l app=gloo-mesh-mgmt-server -o jsonpath='{.items[0].metadata.name}')
kubectl --context ${MGMT_CONTEXT}  -n gloo-mesh debug -it ${pod} --image=curlimages/curl --image-pull-policy=Always -- curl http://localhost:9091/metrics | grep relay_push_clients_connected