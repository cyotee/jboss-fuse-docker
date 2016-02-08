# Use latest jboss/base-jdk:7 image as the base
FROM jboss/base-jdk:7

MAINTAINER Robert Greathouse <robert.i.greathouse@gmail.com>

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
#COPY jboss-fuse /opt/jboss/jboss-fuse
COPY jboss-fuse.tar.gz /opt/jboss/
RUN ls -al /opt/jboss

#COPY fuse/ $FUSE_HOME
RUN tar -zxvf /opt/jboss/jboss-fuse.tar.gz -C /opt/jboss && \
    ls -al /opt/jboss/jboss-fuse && \
    rm /opt/jboss/jboss-fuse.tar.gz

EXPOSE 8181 8101 1099 44444 61616 1883 5672 61613 61617 8883 5671 61614

#
# The following directories can hold config/data, so lets suggest the user
# mount them as volumes.
VOLUME /opt/jboss/jboss-fuse/bin
VOLUME /opt/jboss/jboss-fuse/etc
VOLUME /opt/jboss/jboss-fuse/data
VOLUME /opt/jboss/jboss-fuse/deploy

# lets default to the jboss-fuse dir so folks can more easily navigate to around the server install
WORKDIR /opt/jboss/jboss-fuse
CMD ["/opt/jboss/jboss-fuse/bin/fuse", "server"]
