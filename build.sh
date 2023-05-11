#!/bin/bash

if [ $# -le 0 ]; then
    echo "VERSION is empty"
    exit 1
fi

BASE_IMAGE_PROJECT=$1

BASE_IMAGE_VERSION=$2

echo "$BASE_IMAGE_PROJECT $BASE_IMAGE_VERSION" 

#原始镜像
ORIGIN_TAG=$BASE_IMAGE_PROJECT:$BASE_IMAGE_VERSION

#压缩镜像
SQUASH_TAG=dockerhub.suntekcorps.com:8443/suntek/$BASE_IMAGE_PROJECT:$BASE_IMAGE_VERSION

# sudo docker build -t dockerhub.suntekcorps.com:8443/suntek/vue-msf-docker-swoole-4.x:$VERSION --build-arg version=$VERSION .
#sudo docker build --squash -t dockerhub.suntekcorps.com:8443/suntek/$BASE_IMAGE_PROJECT:$BASE_IMAGE_VERSION --build-arg base_image_project=$BASE_IMAGE_PROJECT --build-arg  base_image_version=$BASE_IMAGE_VERSION .
docker build -t $SQUASH_TAG --build-arg base_image_project=$BASE_IMAGE_PROJECT --build-arg  base_image_version=$BASE_IMAGE_VERSION .
#sudo docker build  -t dockerhub.suntekcorps.com:8443/suntek/$BASE_IMAGE_PROJECT:$BASE_IMAGE_VERSION --build-arg base_image_project=$BASE_IMAGE_PROJECT --build-arg  base_image_version=$BASE_IMAGE_VERSION .

exit 0

# 生成　dockerfile.build 

# echo "FROM $ORIGIN_TAG AS source \n\

# FROM almalinux:8 \n\

# MAINTAINER sunny5156 <sunny5156@qq.com> \n\

# COPY --from=source / / \n\

# EXPOSE 22 80 443 8080 8000 \n\
# ENTRYPOINT [\"\/run.sh\"]

# " > ./Dockerfile.build


# SQUASH_TAG
# docker build  -t $SQUASH_TAG --build-arg base_image_project=$BASE_IMAGE_PROJECT --build-arg  base_image_version=$BASE_IMAGE_VERSION -f ./Dockerfile.build .