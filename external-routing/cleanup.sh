#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

glooctl delete virtualservice default
glooctl delete upstream jsonplaceholder-80  