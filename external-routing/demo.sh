#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD



#glooctl create upstream static jsonplaceholder-80 --static-hosts jsonplaceholder.typicode.com:80

desc "A simple externally routable API: jsonplaceholder"
run "curl http://jsonplaceholder.typicode.com/users"

backtotop

run "curl http://jsonplaceholder.typicode.com/users/1"
backtotop

desc "First, let's create an upstream. Upstreams in Gloo are normally dynamically discovered"
read -s
desc "But we will statically add this one"
run "glooctl create upstream static jsonplaceholder-80 --static-hosts jsonplaceholder.typicode.com:80"

desc "Let's make sure it was accepted:"
run "glooctl get upstream"

backtotop

desc "Now, let's create a route to it:"
run "glooctl add route --dest-name jsonplaceholder-80 --path-exact /api/posts --prefix-rewrite /posts"

desc "Let's check the VirtualService"
run "glooctl get virtualservice"

desc "let's try calling our API"
run "curl $(glooctl proxy url)/api/posts"

