#!/bin/bash


DIR_NAME=$(pwd $(dirname $BASH_SOURCE))
. $(dirname ${BASH_SOURCE})/../../util.sh
. ../.env.sh

desc "Let's see what in the repo"
pushd ../petstore/repo-link 
run "ls -l"

desc "Let's add another apidoc"
run "cp $DIR_NAME/../60-dev-portal/complete/apidoc-special.yaml ."

run "ls -l"

run "git add ."
run "git commit -m 'added new api doc'"
run "git push"


desc "Let's add an API product"
run "cp $DIR_NAME/../60-dev-portal/complete/apiproduct-petstore.yaml ."

run "ls -l"

run "git add ."
run "git commit -m 'added api product'"
run "git push"

desc "Let's add a Portal"
run "cp $DIR_NAME/../60-dev-portal/complete/portal-oidc-petstore.yaml ."

run "ls -l"

run "git add ."
run "git commit -m 'added api portal for petstore'"
run "git push"
popd
