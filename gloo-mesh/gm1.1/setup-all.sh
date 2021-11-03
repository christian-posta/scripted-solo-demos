#!/bin/bash

./setup-vault.sh
echo "Done setting up vault.. press ENTER to continue"
#read -s
./setup-mgmt-plane.sh
echo "Done setting up mgmt plane.. press ENTER to continue"
#read -s
./setup-west-cluster.sh
echo "Done setting up west-cluster.. press ENTER to continue"
#read -s
./setup-east-cluster.sh
echo "Done setting up east cluster.. press ENTER to continue"
#read -s
./demo-init.sh
echo "Done setting up demo-init.. press ENTER to continue"
#read -s
./setup-vault-istiod.sh
echo "Done setting up vault-istiod.. press ENTER to continue"
#read -s
./setup-gitops.sh
echo "Done setting up gitops.. press ENTER to continue"
