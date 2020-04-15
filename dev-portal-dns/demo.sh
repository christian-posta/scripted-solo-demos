#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD

desc "Petstore API"
run "curl http://petstore.myddns.me/api/pets -v"


desc "Open the Gloo UI"
desc "http://glooui.myddns.me"

desc "Open the dev portal:"
desc "http://apis.myddns.me"

read -s

backtotop
desc "Let's apply the virtualservice for api keys"
read -s

run "cat resources/auth-config.yaml"
run "kubectl apply -f resources/auth-config.yaml"

run "cat resources/petstore-vs-auth.yaml"
run "kubectl apply -f resources/petstore-vs-auth.yaml"

