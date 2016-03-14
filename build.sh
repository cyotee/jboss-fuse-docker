#!/bin/bash

FUSE_ARTIFACT_ID=jboss-fuse-karaf-full
echo "Set EV FUSE_ARTIFACT_ID to ${FUSE_ARTIFACT_ID}"
FUSE_VERSION=6.2.0.redhat-099
echo "Set EV FUSE_VERSION to ${FUSE_VERSION}"
FUSE_DISTRO_URL=http://origin-repository.jboss.org/nexus/content/groups/ea/org/jboss/fuse/${FUSE_ARTIFACT_ID}/${FUSE_VERSION}/${FUSE_ARTIFACT_ID}-${FUSE_VERSION}.zip
echo "Set EV FUSE_DISTRO_URL to ${FUSE_DISTRO_URL}"

FUSE_ARTIFACT_ID_FOR_DOCKER=jboss-fuse.tar.gz
echo "Set EV FUSE_ARTIFACT_ID_FOR_DOCKER to ${FUSE_ARTIFACT_ID_FOR_DOCKER}"

echo "Executing install.sh to download an prepare server artifact."
./install.sh
echo "install.sh completed"

#DOCKER_REGISTRY=registry.cloudapps-6b83.oslab.opentlc.com
DOCKER_REGISTRY=docker.io

#DOCKER_REGISTRY_NAMESPACE=fuse-demo
DOCKER_REGISTRY_NAMESPACE=cyotee

DOCKER_IMAGE_NAME=jboss-fuse
#DOCKER_IMAGE_VERSION=$FUSE_VERSION
DOCKER_IMAGE_VERSION=latest

#docker rmi --force=true ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}
#docker build --force-rm=true --rm=true -t ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION} .
echo "Building Docker Image with command docker build -t ${DOCKER_REGISTRY}/${DOCKER_REGISTRY_NAMESPACE}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION} ."
docker build --force-rm=true --rm=true -t ${DOCKER_REGISTRY}/${DOCKER_REGISTRY_NAMESPACE}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION} .
echo =========================================================================
echo Docker image is ready.  Try it out by running:
echo     docker run --rm -ti -P ${DOCKER_IMAGE_NAME}
echo =========================================================================
