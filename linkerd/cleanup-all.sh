#!/bin/bash

killall linkerd
linkerd install --ignore-cluster | kubectl delete -f -