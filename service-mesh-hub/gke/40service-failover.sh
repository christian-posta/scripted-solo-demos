#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

SOURCE_DIR=$PWD
source env.sh


# Delete traffic policy
kubectl delete TrafficPolicy reviews-tp -n service-mesh-hub
