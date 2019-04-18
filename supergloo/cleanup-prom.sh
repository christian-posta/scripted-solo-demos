#!/bin/bash

kubectl edit mesh istio -n supergloo-system
kubectl delete ns prometheus-test