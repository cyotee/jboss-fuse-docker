#!/bin/bash

#DOCKER_REGISTRY=registry.cloudapps-4688.oslab.opentlc.com
#DOCKER_REGISTRY=docker.io

#DOCKER_REGISTRY_NAMESPACE=fuse-demo
#DOCKER_REGISTRY_NAMESPACE=cyotee

#DOCKER_IMAGE_NAME=jboss-fuse-docker
#DOCKER_IMAGE_VERSION=6.2.0.redhat-099

FUSE_ARTIFACT_ID=jboss-fuse-karaf-full
FUSE_VERSION=6.2.0.redhat-099
FUSE_DISTRO_URL=http://origin-repository.jboss.org/nexus/content/groups/ea/org/jboss/fuse/${FUSE_ARTIFACT_ID}/${FUSE_VERSION}/${FUSE_ARTIFACT_ID}-${FUSE_VERSION}.zip


echo "Executing install.sh to download an prepare server artifact."
./install.sh
echo "install.sh completed"
#docker rmi --force=true ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}
#docker build --force-rm=true --rm=true -t ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION} .
echo "Building Docker Image with command docker build -t ${DOCKER_REGISTRY}/${DOCKER_REGISTRY_NAMESPACE}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION} ."
docker build -t ${DOCKER_REGISTRY}/${DOCKER_REGISTRY_NAMESPACE}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION} .
echo =========================================================================
echo Docker image is ready.  Try it out by running:
echo     docker run --rm -ti -P ${DOCKER_IMAGE_NAME}
echo =========================================================================
