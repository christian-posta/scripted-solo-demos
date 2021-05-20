#!/bin/bash

source env.sh

echo "Consider using meshctl dashboard"
echo "Press enter to continue"
read -s

EXISTING_PID=$(ps aux | grep port-forward | grep svc/dashboard | awk '{print $2}')
kill -9 $EXISTING_PID
kubectl --context port-forward -n gloo-mesh svc/dashboard 8090  > /dev/null 2>&1 &
echo "Gloo Mesh read-only UI available on http://localhost:8090/"


