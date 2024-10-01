#!/bin/bash

TASK_ID=$(aws ecs list-tasks --cluster ceposta-ecs-ambient --service shell-ztunnel | grep ceposta-ecs-ambient | tr -d '"' | cut -d '/' -f 3)

aws ecs execute-command --cluster ceposta-ecs-ambient --task $TASK_ID --interactive --container shell --command sh


