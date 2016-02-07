# Use latest jboss/base-jdk:7 image as the base
FROM jboss/base-jdk:7

MAINTAINER Robert Greathouse <robert.i.greathouse@gmail.com>

# Set the FUSE_VERSION env variable
ENV FUSE_VERSION 6.2.0.redhat-099
ENV FUSE_ARTIFACT_ID=jboss-fuse-karaf-full
ENV FUSE_DISTRO_URL=http://origin-repository.jboss.org/nexus/content/groups/ea/org/jboss/fuse/${FUSE_ARTIFACT_ID}/${FUSE_VERSION}/${FUSE_ARTIFACT_ID}-${FUSE_VERSION}.zip
ENV $JBOSS_DIR=/opt/jboss
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
#

RUN curl -O /$JBOSS_DIR/${FUSE_DISTRO_URL} && \
    jar -xvf /$JBOSS_DIR/${FUSE_ARTIFACT_ID}-${FUSE_VERSION}.zip -C $JBOSS_DIR/jboss-fuse && \
    chmod a+x /$JBOSS_DIR/jboss-fuse/bin/* && \
    rm /$JBOSS_DIR/jboss-fuse/bin/*.bat && \
    rm /$JBOSS_DIR/jboss-fuse/bin/start && \
    rm /$JBOSS_DIR/jboss-fuse/bin/stop && \
    rm /$JBOSS_DIR/jboss-fuse/bin/status && \
    rm /$JBOSS_DIR/jboss-fuse/bin/patch && \
    rm -rf /$JBOSS_DIR/jboss-fuse/extras && \
    rm -rf /$JBOSS_DIR/jboss-fuse/quickstarts && \
    sed -i -e 's/environment.prefix=FABRIC8_/environment.prefix=FUSE_/' jboss-fuse/etc/system.properties && \
    sed -i -e '/karaf.name = root/d' jboss-fuse/etc/system.properties && \
    sed -i -e '/runtime.id=/d' jboss-fuse/etc/system.properties && \
    echo 'if [ -z "$FUSE_KARAF_NAME" ]; then export FUSE_KARAF_NAME="$HOSTNAME" fi if [ -z "$FUSE_RUNTIME_ID" ]; then export FUSE_RUNTIME_ID="$FUSE_KARAF_NAME" fi export KARAF_OPTS="-Dkaraf.name=${FUSE_KARAF_NAME} -Druntime.id=${FUSE_RUNTIME_ID}"' >> jboss-fuse/bin/setenv && \
    mv jboss-fuse/data/tmp jboss-fuse/tmp && \
    echo 'org.osgi.framework.storage=${karaf.base}/tmp/cache'>> jboss-fuse/etc/config.properties && \
    sed -i -e 's/-Djava.io.tmpdir="$KARAF_DATA\/tmp"/-Djava.io.tmpdir="$KARAF_BASE\/tmp"/' jboss-fuse/bin/karaf && \
    sed -i -e 's/-Djava.io.tmpdir="$KARAF_DATA\/tmp"/-Djava.io.tmpdir="$KARAF_BASE\/tmp"/' jboss-fuse/bin/fuse && \
    sed -i -e 's/-Djava.io.tmpdir="$KARAF_DATA\/tmp"/-Djava.io.tmpdir="$KARAF_BASE\/tmp"/' jboss-fuse/bin/client && \
    sed -i -e 's/-Djava.io.tmpdir="$KARAF_DATA\/tmp"/-Djava.io.tmpdir="$KARAF_BASE\/tmp"/' jboss-fuse/bin/admin && \
    sed -i -e 's/${karaf.data}\/generated-bundles/${karaf.base}\/tmp\/generated-bundles/' jboss-fuse/etc/org.apache.felix.fileinstall-deploy.cfg && \
    sed -i -e 's/karaf.delay.console=true/karaf.delay.console=false/' jboss-fuse/etc/config.properties;


COPY users.properties $JBOSS_DIR/jboss-fuse/etc/users.properties
COPY install.sh /opt/jboss/install.sh
RUN /opt/jboss/install.sh

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
CMD /opt/jboss/jboss-fuse/bin/fuse server
