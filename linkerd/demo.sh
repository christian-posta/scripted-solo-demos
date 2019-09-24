#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD

desc "Open the linkerd dashboard"
run "linkerd dashboard &"


desc "Let's install the demo book app"
run "cat $(relative booksapp.yaml) | linkerd inject - | kubectl apply -n booksapp -f -"

desc "Open the webapp"
run "kubectl -n booksapp port-forward svc/webapp 7000 &"
run "open http://localhost:7000"

desc "Go dig into where we think the issue is using Linkerd's console"
read -s

desc "Now, let's at a bit more structure to our understanding of the call paths"
desc "Let's say we had a OpenAPI Spec doc for thee webapp:"
run "cat $(relative webapp.swagger)"

desc "Create a service profile for this spec/app"
run "linkerd -n booksapp profile --open-api $(relative webapp.swagger) webapp"
run "linkerd -n booksapp profile --open-api $(relative webapp.swagger) webapp | kubectl apply -f -"

desc "do the same for the two other services"
run "linkerd -n booksapp profile --open-api $(relative books.swagger) books | kubectl apply -f -"
run "linkerd -n booksapp profile --open-api $(relative authors.swagger) authors | kubectl apply -f -"

desc "now let's look at a tap of the live traffic"
run "linkerd -n booksapp tap deploy/webapp -o wide | grep req"

desc "Now let's see the accumlated metrics with the newly annotated dimensions"
run "linkerd -n booksapp routes svc/webapp"

desc "Let's narrow down the scope of the metrics from webapp to svc/books"
run "linkerd -n booksapp routes deploy/webapp --to svc/books"

desc "Let's add retries to cut down on the failed calls"
run "linkerd -n booksapp routes deploy/books --to svc/authors"
run "kubectl -n booksapp edit sp/authors.booksapp.svc.cluster.local"
run "linkerd -n booksapp routes deploy/books --to svc/authors -o wide"

desc "cleanup"
read -s
run "killall linkerd"
run "killall kubectl"

