#!/bin/bash

./setup-vault.sh
./setup-mgmt-plane.sh
./setup-west-cluster.sh
./setup-east-cluster.sh
./demo-init.sh
./setup-vault-istiod.sh
./setup-gitops.sh
