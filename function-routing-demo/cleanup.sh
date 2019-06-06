#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

glooctl delete virtualservice petstore
