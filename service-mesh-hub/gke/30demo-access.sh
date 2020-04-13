#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

SOURCE_DIR=$PWD
source env.sh


desc "We've seen some basics around traffic routing"
desc "Now let's take a look at access control"
read -s


backtotop
desc "We may not want every service to be able to talk with every other"
desc "Let's enforce access policies by starting with a Deny All posture"
read -s

run "cat resources/virtual-mesh-access.yaml"

exit
