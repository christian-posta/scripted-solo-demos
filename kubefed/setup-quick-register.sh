#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD
source env.sh


kubefedctl join cluster1 --cluster-context cluster1 --host-cluster-context cluster1 --v 2
kubefedctl join cluster2 --cluster-context cluster2 --host-cluster-context cluster1 --v 2
./resources/fix-joined-kind-clusters.sh > /dev/null 2>&1

kubectl get kubefedclusters -A -o yaml

