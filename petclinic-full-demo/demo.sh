#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD

desc "Let's take a look at the upstreams we have:"
run "glooctl get upstream"


desc "Let's create the default route to petclinic so we can open it in a browser:"
run "glooctl add route --dest-name default-petclinic-80  --path-prefix /"

desc "Let's open up the UI"
run "open $(glooctl proxy url)"

backtotop

desc "Let's add a route for the go-microservice"
run "glooctl add route --dest-name default-petclinic-vets-80  --path-prefix /vet --name default"

desc "Let's add an AWS upstream"
desc "Note, we need the AWS secret installed beforehand. Go do that now"
read -s
backtotop

desc "Create AWS secrets"
# basically, just run something like this in a scrip on the path:
# glooctl create secret aws --access-key $AWS_ACCESS_KEY --secret-key $AWS_SECRET_KEY --name aws-credentials
#run "create-aws-secret"

desc "Now that we have the AWS secret, we create the upstream"
run "glooctl create upstream aws aws --aws-region us-east-1 --aws-secret-name aws-credentials"

desc "Let's get the AWS upstream"
run "glooctl get upstream aws"
run "glooctl get upstream aws -o yaml"

desc "Add the route to the AWS lambda"
run "glooctl add route --name default --dest-name aws --aws-function-name contact-form:3 --aws-unescape  --path-prefix /contact"
