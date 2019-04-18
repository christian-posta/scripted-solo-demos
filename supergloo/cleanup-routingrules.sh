#!/bin/bash

kubectl delete routingrules reviews-v3 -n supergloo-system 
kubectl delete routingrules rule1 -n supergloo-system 
kubectl delete securityrule -n default --all