#!/bin/bash

glooctl delete virtualservice default
kubectl delete secret aws-credentials -n gloo-system
glooctl delete us aws