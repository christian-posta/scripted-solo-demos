#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD
CERT_DIR="./certs/"

desc "Let's take a look at the certs we want to use"
run "ls -l ${CERT_DIR}"

desc "Let's take a look at the root cert"
run "cat ${CERT_DIR}root-cert.pem"

desc "Let's wrap these certs into a kubernetes tls secret"
run "supergloo create secret tls --name my-root-ca \
    --cacert ${CERT_DIR}ca-cert.pem \
    --cakey ${CERT_DIR}ca-key.pem \
    --rootcert ${CERT_DIR}root-cert.pem \
    --certchain ${CERT_DIR}cert-chain.pem "

run "kubectl get secret my-root-ca -o yaml -n supergloo-system"
backtotop

desc "Now let's swap this root ca in Istio Citadel"
run "supergloo set mesh rootcert --target-mesh supergloo-system.istio \
    --tls-secret supergloo-system.my-root-ca"

RATINGSPOD=`kubectl get pods -n default -l app=ratings -o jsonpath='{.items[0].metadata.name}'`
mkdir temp-pod

TEMP_POD_DIR="./temp-pod/"

tmux split-window -v -d -c $SOURCE_DIR
tmux select-pane -t 0

desc "Let's grab the ratings pod's certificates so we can diff"
read -s

tmux send-keys -t 1 "rm temp-pod/pod-*" C-m

read -s

tmux send-keys -t 1 "kubectl exec -n default -it $RATINGSPOD -c istio-proxy -- /bin/cat /etc/certs/root-cert.pem > ${TEMP_POD_DIR}pod-root-cert.pem" C-m


desc "Let's grab the text of the certs so we can compare them"
run "openssl x509 -in ${CERT_DIR}root-cert.pem -text -noout > ${TEMP_POD_DIR}root-cert.crt.txt"

tmux send-keys -t 1 "openssl x509 -in ${TEMP_POD_DIR}pod-root-cert.pem -text -noout > ${TEMP_POD_DIR}pod-root-cert.crt.txt" C-m

desc "now let's diff"
read -s

tmux send-keys -t 1 "diff ${TEMP_POD_DIR}root-cert.crt.txt ${TEMP_POD_DIR}pod-root-cert.crt.txt" C-m

desc "We may need to re-run these commands"
read -s
    

desc "Clean up"
run "kubectl edit mesh istio -n supergloo-system"
run "kubectl delete secret my-root-ca -n supergloo-system"    
rm -fr temp-pod