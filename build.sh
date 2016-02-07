DOCKER_IMAGE_NAME=jboss/jboss-fuse-full
DOCKER_IMAGE_VERSION=latest

echo "Executing install.sh to download an prepare server artifact."
./install.sh
echo "install.sh completed"
#docker rmi --force=true ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}
#docker build --force-rm=true --rm=true -t ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION} .
echo "Building Docker Image"
docker build -t ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION} .
echo =========================================================================
echo Docker image is ready.  Try it out by running:
echo     docker run --rm -ti -P ${DOCKER_IMAGE_NAME}
echo =========================================================================
