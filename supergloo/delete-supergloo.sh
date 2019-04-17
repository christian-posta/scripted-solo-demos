#!/bin/bash

kubectl delete ns supergloo-system
kubectl delete crd $(k get crd | grep supergloo | awk '{ print $1 }')