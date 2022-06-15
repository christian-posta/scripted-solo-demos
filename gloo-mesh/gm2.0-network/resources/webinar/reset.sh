#!/bin/bash



kubectl --context gm-cluster1 delete -f resources/webinar/default-peer-authentication.yaml

kubectl -n bookinfo scale deploy/details-v1 --replicas=1
kubectl -n bookinfo delete CiliumNetworkPolicy --all 

kubectl --context gm-cluster1 delete -f resources/webinar/reviews-accesspolicy.yaml
kubectl --context gm-cluster1 delete -f resources/webinar/workspacesettings.yaml
