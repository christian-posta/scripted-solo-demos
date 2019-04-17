#!/bin/bash

squashctl utils delete-attachments
kubectl delete deploy example-service1 example-service2-java
kubectl delete svc example-service1 example-service2-java
kubectl delete ns squash-debugger