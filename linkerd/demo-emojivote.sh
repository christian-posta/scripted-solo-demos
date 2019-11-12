#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD


# Run this if you cannot see taps
# kubectl create clusterrolebinding $(whoami)-tap-admin --clusterrole=linkerd-linkerd-tap-admin  --user=$(gcloud config get-value account)

desc "Make sure Linkerd is installed"
read -s


desc "Open the linkerd dashboard"
run "linkerd dashboard &"


desc "Let's install the emojivoto demo"
run "kubectl create ns emojivoto"
run "curl -sL https://run.linkerd.io/emojivoto.yml | linkerd inject - | kubectl apply -f -"

desc "Open the webapp"
run "kubectl -n emojivoto port-forward svc/web-svc 8080:80 &"
run "open http://localhost:8080"

desc "Go dig into where we think the issue is using Linkerd's console"
read -s

desc "View stats"
run "linkerd -n emojivoto stat deploy"
run "linkerd -n emojivoto top deploy"

desc "We could also use the tap command to see the messages (do in another window?)"
#run "linkerd -n emojivoto tap deploy/web"

desc "cleanup"
read -s
run "killall linkerd"
run "killall kubectl"
run "curl -sL https://run.linkerd.io/emojivoto.yml | linkerd inject - | kubectl delete -f -"
run "kubectl delete ns emojivoto"
