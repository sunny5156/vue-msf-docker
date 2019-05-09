#!/bin/bash
TAG="190.168.3.239/sfc/${1}:${2}"
t=$(echo $TAG | tr '[A-Z]' '[a-z]') 
docker build --tag $t --build-arg project=$1 --build-arg version=$2 --build-arg msf_env=$3 .