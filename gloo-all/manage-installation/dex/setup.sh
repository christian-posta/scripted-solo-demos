# dex
DIR=$(dirname ${BASH_SOURCE})
helm install dex --namespace gloo-system --version 2.9.0 stable/dex -f $DIR/../../resources/dex/values.yaml
glooctl create secret oauth --client-secret secretvalue oauth &> /dev/null