#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

SOURCE_DIR=$PWD
source env.sh
kubectl config use-context $MGMT_CONTEXT


desc "We are logged in as user 'kubernetes-admin' "
desc "We have an admin role that allows a user to do anything on the application network"

run "kubectl get role.rbac.enterprise -n gloo-mesh"
run "kubectl get role.rbac.enterprise -n gloo-mesh admin-role -o yaml"

desc "Let's see the binding to the kubernetes-admin user"
run "kubectl get rolebinding.rbac.enterprise -n gloo-mesh -o yaml"

desc "What if we try to create a traffic policy when logged in as a different user?"
run ""