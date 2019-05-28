#!/bin/bash

kubectl -n gloo-system port-forward svc/flagger-prometheus 9090