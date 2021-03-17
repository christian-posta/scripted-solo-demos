#!/bin/bash


DIR_NAME=$(pwd $(dirname $BASH_SOURCE))
. $(dirname ${BASH_SOURCE})/../../util.sh
. ../.env.sh

desc "Let's see what in the repo"
pushd ../petclinic/repo-link 
run "ls -l"
run "ls -l ./resources"

desc "Let's add a gloo routing config"
run "cp $DIR_NAME/../resources/gloo/petclinic-vs.yaml ./resources"

run "ls -l ./resources"

run "git add ."
run "git commit -m 'added gloo routing'"
run "git push"


desc "Let's change the routing to the new vets service"
run "cp $DIR_NAME/../resources/gloo/petclinic-vs-vets.yaml ./resources/petclinic-vs.yaml"

run "ls -l ./resources"

run "git add ."
run "git commit -m 'updated to new service'"
run "git push"
popd
