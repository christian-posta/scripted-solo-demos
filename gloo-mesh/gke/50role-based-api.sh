#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

SOURCE_DIR=$PWD
source env.sh
kubectl config use-context $MGMT_CONTEXT


desc "We are logged in as user 'kubernetes-admin' "
desc "We have an admin role that allows a user to do anything on the application network"

run "kubectl get role.rbac.enterprise -n gloo-mesh"
run "kubectl neat get -- role.rbac.enterprise -n gloo-mesh admin-role"

backtotop
desc "Let's see the binding to the kubernetes-admin user"
read -s

run "kubectl neat get -- rolebinding.rbac.enterprise -n gloo-mesh"

backtotop
desc "What if we try to create a traffic policy when logged in as a different user?"
read -s

run "cat ./role-based-api/02-trafficpolicy-fault-injection-sre.yaml"
run "KUBECONFIG=./user/user-sre/user-sre-kubeconfig kubectl apply -f ./role-based-api/02-trafficpolicy-fault-injection-sre.yaml"

backtotop
desc "We need to give this user-sre permissions to access that API"
read -s
run "cat ./role-based-api/50-svc-sre.yaml"
run "kubectl apply -f ./role-based-api/50-svc-sre.yaml"

backtotop
desc "Now try create that policy"
read -s

run "KUBECONFIG=./user/user-sre/user-sre-kubeconfig kubectl apply -f ./role-based-api/02-trafficpolicy-fault-injection-sre.yaml"

desc "What if the SRE user tries to create an access policy?"
run "cat ./role-based-api/10-accesspolicy.yaml"
run "KUBECONFIG=./user/user-sre/user-sre-kubeconfig kubectl apply -f ./role-based-api/10-accesspolicy.yaml"

desc "Demo is done!"
read -s
desc "Press ENTER to cleanup... or CTRL+C to exit out here"
read -s
kubectl delete -f ./role-based-api/02-trafficpolicy-fault-injection-sre.yaml
kubectl delete -f ./role-based-api/50-svc-sre.yaml