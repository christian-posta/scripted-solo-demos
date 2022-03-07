#!/bin/bash

source ./env-workshop.sh


# set up workspaces
./deploy-lab6-workspaces.sh
./deploy-lab7-virtualgateway.sh

./deploy-lab9-rootca.sh

