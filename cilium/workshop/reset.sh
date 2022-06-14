#!/bin/bash



kubectl -n bookinfo scale deploy/details-v1 --replicas=1
kubectl -n bookinfo delete CiliumNetworkPolicy --all 
