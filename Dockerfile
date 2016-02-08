# Use latest jboss/base-jdk:7 image as the base
FROM jboss/base-jdk:7

MAINTAINER Robert Greathouse <robert.i.greathouse@gmail.com>

ENV JBOSS_DIR /opt/jboss
#ENV FUSE_ARTIFACT_ID_FOR_DOCKER jboss-fuse.tar.gz
ENV FUSE_HOME $JBOSS_DIR/jboss-fuse

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
COPY jboss-fuse.tar.gz $JBOSS_DIR
RUN tar -zxvf $JBOSS_DIR/$FUSE_ARTIFACT_ID_FOR_DOCKER -C $JBOSS_DIR && \
    rm $JBOSS_DIR/$FUSE_ARTIFACT_ID_FOR_DOCKER
#COPY fuse/ $FUSE_HOME

EXPOSE 8181 8101 1099 44444 61616 1883 5672 61613 61617 8883 5671 61614

#
# The following directories can hold config/data, so lets suggest the user
# mount them as volumes.
VOLUME $FUSE_HOME/bin
VOLUME $FUSE_HOME/etc
VOLUME $FUSE_HOME/data
VOLUME $FUSE_HOME/deploy

# lets default to the jboss-fuse dir so folks can more easily navigate to around the server install
WORKDIR $FUSE_HOME
CMD $FUSE_HOME/bin/fuse server
