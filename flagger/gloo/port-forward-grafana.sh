#!/bin/bash

kubectl -n gloo-system port-forward svc/flagger-grafana 8080:80