../deploy.sh 1 gm-mgmt
../deploy.sh 2 gm-cluster1 us-west us-west-1
../deploy.sh 3 gm-cluster2 us-east us-east-1

kubectl config use-context gm-mgmt