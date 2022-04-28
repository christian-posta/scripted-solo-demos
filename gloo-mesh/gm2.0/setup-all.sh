#!/bin/bash

./00-setup-mgmt-plane.sh
./10-setup-west-cluster.sh
./20-setup-east-cluster.sh
./30-setup-sample-apps.sh
./35-setup-base-configs.sh