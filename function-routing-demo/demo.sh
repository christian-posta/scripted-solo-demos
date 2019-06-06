#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD

desc "We depend on having the petstore upstream installed. Please restart demo if it's not:"
read -s

backtotop

desc "Let's review the petstore upstream"
run "glooctl get upstream default-petstore-8080 -o yaml"

backtotop


desc "These transformations are Inja templates that automatically know how to convert a request for a specific function into that shape"
desc "These mappings happen automatically -- you can customize them, but you don't have to write them ahead of time"

read -s
backtotop

desc "Let's route to a specific function (not just a reverse proxy)"
run "glooctl create virtualservice --name petstore --domains petstore.solo.io"
run "glooctl add route --name petstore  --path-exact /petstore/findPet --dest-name default-petstore-8080 --rest-function-name findPetById"

desc "If we canll our service, we should see that it defaults to getting all pets"
run "curl -H 'Host: petstore.solo.io' $(glooctl proxy url)/petstore/findPet"

desc "The findPetById function expects a parameter though. It will default to empty string. Where does this parameter come from?"
desc "We can send it in via the body"
read -s

run "curl -H 'Host: petstore.solo.io' $(glooctl proxy url)/petstore/findPet -d '{\"id\": 1}'"

desc "This is a simple example. This sample is subtle, but here's what's going on:"
read -s

desc "We are decoupling the frontend users from the backend functions."
desc "We can take reqeusts in a certain shape and transform them into requests that match the signature of the function AUTOMATICALLY"
read -s

desc "We can also read the parameters for a function from the headers"


run "glooctl add route --name petstore --path-prefix /petstore/findWithId/ --dest-name default-petstore-8080  --rest-function-name findPetById --rest-parameters ':path=/petstore/findWithId/{id}'"


run "curl -H 'Host: petstore.solo.io' $(glooctl proxy url)/petstore/findWithId/1"

