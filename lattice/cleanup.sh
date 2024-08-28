#!/bin/bash


# remove the import of the inventory -v2 service from cluster 1
kubectl --context ceposta-eks-1 delete -f resources/inventory-ver2-import.yaml

# don't delete; just override
#kubectl --context ceposta-eks-1 delete -f resources/inventory-route-bluegreen.yaml

kubectl --context ceposta-eks-1 apply -f resources/inventory-route.yaml