#!/bin/bash

echo "Uninstall flagger, gloo, test"

helm del --purge gloo
helm del --purge flagger
helm del --purge flagger-loadtester
