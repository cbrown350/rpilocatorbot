#!/bin/bash

export TAG=`jq -r ".docker_image_name" < ./package.json`
echo "Tagging image as '${TAG}'"
export PROJECT_VERSION=`jq -r ".version" < ./package.json`
export REPO_URL=`jq -r ".repository.url" < ./package.json | cut -d"@" -f2 | sed -r 's-((^https?:\/\/)?([0-9a-z\/_\-\.]*))-\L\3>-gi' | sed -r 's-(>:)|(>)-/-gi' | sed 's:/*$::'`
unset LABEL_OPT
[ ! -z $REPO_URL ] && [[ $REPO_URL == *"ghcr.io"* ]] && export LABEL_OPT="--label 'org.opencontainers.image.source=https://$REPO_URL'"
docker pull $TAG:latest
docker build --cache-from $LABEL_OPT $TAG:latest -t $TAG -t $TAG:$PROJECT_VERSION .
docker push $TAG
docker push $TAG:$PROJECT_VERSION