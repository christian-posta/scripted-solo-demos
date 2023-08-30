../deploy-with-cilium.sh 1 gm-mgmt
../deploy-with-cilium.sh 2 gm-cluster1 us-west us-west-1
../deploy-with-cilium.sh 3 gm-cluster2 us-east us-east-1

kubectl config use-context gm-mgmt