../scripts/deploy-with-cilium.sh 1 mgmt
../scripts/deploy-with-cilium.sh 2 cluster1 us-west us-west-1
../scripts/deploy-with-cilium.sh 3 cluster2 us-east us-east-1

kubectl config use-context mgmt
