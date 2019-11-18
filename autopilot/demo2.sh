#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD
export GOPRIVATE=github.com/solo-io/autopilot

pushd autorouter > /dev/null 2>&1

desc "Auto pilot demo, part 2!"
read -s
desc "Open up spec.go in your IDE"
run "cat pkg/apis/autoroutes/v1/spec.go"


desc "Press Enter to update the spec.go with our proto"
read -s
cp ../resources/spec.go pkg/apis/autoroutes/v1/spec.go

desc "Now go check out spec.go in your IDE"
read -s

desc "Let's regenerate our code again"
run "ap generate --deepcopy-only"

backtotop
read -s
desc "Now let's implement the workers!"
run "tree pkg/workers"

desc "Go checkout the Initializting worker in your IDE"
read -s

desc "Press Enter to copy in the new Init worker"
cp ../resources/init-worker.go pkg/workers/initializing/worker.go
read -s

desc "Now let's update the sync worker. Check it out in your IDE"
read -s

desc "Press Enter to copy in the Sync worker"
cp ../resources/sync-worker.go pkg/workers/syncing/worker.go
read -s

desc "Now let's update the Ready worker"
read -s

desc "Press Enter to copy in the Ready worker"
cp ../resources/ready-worker.go pkg/workers/ready/worker.go
read -s

desc "Go to part 3!"