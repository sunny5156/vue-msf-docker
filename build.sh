#!/bin/bash

if [ $# -le 0 ]; then
    echo "VERSION is empty"
    exit 1
fi

BASE_IMAGE_PROJECT=$1

BASE_IMAGE_VERSION=$2

echo "$BASE_IMAGE_PROJECT $BASE_IMAGE_VERSION" 

# sudo docker build -t dockerhub.suntekcorps.com:8443/suntek/vue-msf-docker-swoole-4.x:$VERSION --build-arg version=$VERSION .
#sudo docker build --squash -t dockerhub.suntekcorps.com:8443/suntek/$BASE_IMAGE_PROJECT:$BASE_IMAGE_VERSION --build-arg base_image_project=$BASE_IMAGE_PROJECT --build-arg  base_image_version=$BASE_IMAGE_VERSION .
sudo docker build  -t dockerhub.suntekcorps.com:8443/suntek/$BASE_IMAGE_PROJECT:$BASE_IMAGE_VERSION --build-arg base_image_project=$BASE_IMAGE_PROJECT --build-arg  base_image_version=$BASE_IMAGE_VERSION .
