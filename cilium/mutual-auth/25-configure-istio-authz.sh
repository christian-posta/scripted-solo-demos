#!/bin/bash



# add services to ambient
kubectl label namespace default istio.io/dataplane-mode=ambient
kubectl apply -f istio/peerauth.yaml
kubectl apply -f istio/policy-deny-all.yaml
kubectl apply -f istio/policy-authz.yaml