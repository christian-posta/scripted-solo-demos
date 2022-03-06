#!/bin/bash

source ./env-workshop.sh


kubectl --context $MGMT apply -f lab9-rootcert.yaml

