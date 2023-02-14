#!/bin/bash

export TAG=${TAG:=registry.gitlab.com/cbrown350/rpilocatorbot}
echo "Tagging image as '${TAG}'"
export PROJECT_VERSION=`jq -r ".version" < ./package.json`
docker pull $TAG:latest
docker build --cache-from $TAG:latest -t $TAG -t $TAG:$PROJECT_VERSION .
docker push $TAG
docker push $TAG:$PROJECT_VERSION