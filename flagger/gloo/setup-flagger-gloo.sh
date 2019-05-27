#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

SOURCE_DIR=$PWD

kubectl create ns test

helm repo add gloo https://storage.googleapis.com/solo-public-helm
helm upgrade -i gloo gloo/gloo --namespace gloo-system


helm repo add flagger https://flagger.app
helm upgrade -i flagger flagger/flagger --namespace gloo-system --set prometheus.install=true --set meshProvider=gloo

helm upgrade -i flagger-grafana flagger/grafana --namespace=gloo-system --set url=http://prometheus:9090