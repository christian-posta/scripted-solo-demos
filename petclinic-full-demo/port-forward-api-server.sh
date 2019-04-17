#!/bin/bash
kubectl port-forward -n gloo-system deployment/api-server 8088

