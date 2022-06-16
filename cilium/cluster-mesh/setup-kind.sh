../scripts/deploy-multi-without-cni.sh 1 cluster1 us-west us-west-1
../scripts/deploy-multi-without-cni.sh 2 cluster2 us-east us-east-1

kubectl config use-context cluster1
