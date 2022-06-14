#!/bin/bash
source ./env.sh

echo "removing output dir"
rm -rf _output

echo "creating output dir"
mkdir _output

echo "creating gitignore"
touch ./_output/.gitignore

echo "staring connection to mgmt plane server..."
kubectl --context $MGMT -n gloo-mesh port-forward deploy/gloo-mesh-mgmt-server 9091 &> /dev/null &
PF_PID="$!"
echo "PID of port-forward: $PF_PID"

function cleanup {
  kill -9 $PF_PID
}

echo "waiting for port-forward..."
sleep 3s

trap cleanup EXIT

echo "curling input snapshot"
curl localhost:9091/snapshots/input -o ./_output/input_snapshot.json 

echo "curling output snapshot"
curl localhost:9091/snapshots/output -o ./_output/output_snapshot.json