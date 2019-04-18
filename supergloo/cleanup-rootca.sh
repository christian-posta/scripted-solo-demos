#!/bin/bash

kubectl edit mesh istio -n supergloo-system
kubectl delete secret my-root-ca -n supergloo-system
rm -fr temp-pod