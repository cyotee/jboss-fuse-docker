# Use latest jboss/base-jdk:7 image as the base
FROM jboss/base-jdk:7

MAINTAINER Robert Greathouse <robert.i.greathouse@gmail.com>

# Set the FUSE_VERSION env variable
#ENV FUSE_VERSION 6.2.0.redhat-099
#ENV FUSE_ARTIFACT_ID=jboss-fuse-karaf-full
ENV FUSE_ARTIFACT_ID=fuse.zip
#ENV FUSE_DISTRO_URL=http://origin-repository.jboss.org/nexus/content/groups/ea/org/jboss/fuse/${FUSE_ARTIFACT_ID}/${FUSE_VERSION}/${FUSE_ARTIFACT_ID}-${FUSE_VERSION}.zip
ENV JBOSS_DIR=/opt/jboss
ENV FUSE_HOME=$JBOSS_DIR/fuse

# If the container is launched with re-mapped ports, these ENV vars should
# be set to the remapped values.
ENV FUSE_PUBLIC_OPENWIRE_PORT 61616
ENV FUSE_PUBLIC_MQTT_PORT 1883
ENV FUSE_PUBLIC_AMQP_PORT 5672
ENV FUSE_PUBLIC_STOMP_PORT 61613
ENV FUSE_PUBLIC_OPENWIRE_SSL_PORT 61617
ENV FUSE_PUBLIC_MQTT_SSL_PORT 8883
ENV FUSE_PUBLIC_AMQP_SSL_PORT 5671
ENV FUSE_PUBLIC_STOMP_SSL_PORT 61614

# Install fuse in the image.
COPY $FUSE_ARTIFACT_ID $JBOSS_DIR
RUN jar -xvf $JBOSS_DIR/${FUSE_ARTIFACT_ID} && \
    rm /$JBOSS_DIR/$FUSE_ARTIFACT_ID
COPY fuse/ $FUSE_HOME

EXPOSE 8181 8101 1099 44444 61616 1883 5672 61613 61617 8883 5671 61614

#
# The following directories can hold config/data, so lets suggest the user
# mount them as volumes.
VOLUME $JBOSS_DIR/jboss-fuse/bin
VOLUME $JBOSS_DIR/jboss-fuse/etc
VOLUME $JBOSS_DIR/jboss-fuse/data
VOLUME $JBOSS_DIR/jboss-fuse/deploy

# lets default to the jboss-fuse dir so folks can more easily navigate to around the server install
WORKDIR $JBOSS_DIR/jboss-fuse
CMD $JBOSS_DIR/jboss-fuse/bin/fuse server
