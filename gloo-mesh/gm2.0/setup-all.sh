#!/bin/bash


./setup-mgmt-plane.sh
echo "Done setting up mgmt plane.. press ENTER to continue"
#read -s
./setup-west-cluster.sh
echo "Done setting up west-cluster.. press ENTER to continue"
#read -s
./setup-east-cluster.sh
echo "Done setting up east cluster.. press ENTER to continue"
#read -s


source env.sh


pod=$(kubectl --context ${MGMT_CONTEXT} -n gloo-mesh get pods -l app=gloo-mesh-mgmt-server -o jsonpath='{.items[0].metadata.name}')
kubectl --context ${MGMT_CONTEXT}  -n gloo-mesh debug -it ${pod} --image=curlimages/curl --image-pull-policy=Always -- curl http://localhost:9091/metrics | grep relay_push_clients_connected

