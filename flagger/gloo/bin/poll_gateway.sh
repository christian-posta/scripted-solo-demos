#!/bin/bash


URL=$(glooctl proxy url)
echo "$URL"

while true
do curl $URL
sleep .5
done

