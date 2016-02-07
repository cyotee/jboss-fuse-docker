# Use latest jboss/base-jdk:7 image as the base
FROM jboss/base-jdk:7

MAINTAINER Robert Greathouse <robert.i.greathouse@gmail.com>

# Set the FUSE_VERSION env variable
ENV FUSE_VERSION 6.2.0.redhat-099
ENV FUSE_ARTIFACT_ID=jboss-fuse-karaf-full
ENV FUSE_DISTRO_URL=http://origin-repository.jboss.org/nexus/content/groups/ea/org/jboss/fuse/${FUSE_ARTIFACT_ID}/${FUSE_VERSION}/${FUSE_ARTIFACT_ID}-${FUSE_VERSION}.zip
ENV JBOSS_DIR=/opt/jboss
ENV FUSE_DIR=$JBOSS_DIR/jboss-fuse
ENV FUSE_HOME=$FUSE_DIR/bin
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
RUN mkdir $JBOSS_DIR
RUN mkdir $JBOSS_DIR/

RUN curl -O  ${FUSE_DISTRO_URL} && \
    jar -xvf ${FUSE_ARTIFACT_ID}-${FUSE_VERSION}.zip -C $JBOSS_DIR/jboss-fuse && \
    rm ${FUSE_ARTIFACT_ID}-${FUSE_VERSION}.zip && \
    chmod a+x $JBOSS_DIR/jboss-fuse/bin/* && \
    rm $JBOSS_DIR/jboss-fuse/bin/*.bat && \
    rm $JBOSS_DIR/jboss-fuse/bin/start && \
    rm $JBOSS_DIR/jboss-fuse/bin/stop && \
    rm $JBOSS_DIR/jboss-fuse/bin/status && \
    rm $JBOSS_DIR/jboss-fuse/bin/patch && \
    rm -rf $JBOSS_DIR/jboss-fuse/extras && \
    rm -rf $JBOSS_DIR/jboss-fuse/quickstarts && \
    sed -i -e 's/environment.prefix=FABRIC8_/environment.prefix=FUSE_/' $JBOSS_DIR/jboss-fuse/etc/system.properties && \
    sed -i -e '/karaf.name = root/d' $JBOSS_DIR/jboss-fuse/etc/system.properties && \
    sed -i -e '/runtime.id=/d' $JBOSS_DIR/jboss-fuse/etc/system.properties && \
    mv $JBOSS_DIR/jboss-fuse/data/tmp $JBOSS_DIR/jboss-fuse/tmp && \
    echo 'org.osgi.framework.storage=${karaf.base}/tmp/cache'>> $JBOSS_DIR/jboss-fuse/etc/config.properties && \
    sed -i -e 's/-Djava.io.tmpdir="$KARAF_DATA\/tmp"/-Djava.io.tmpdir="$KARAF_BASE\/tmp"/' $JBOSS_DIR/jboss-fuse/bin/karaf && \
    sed -i -e 's/-Djava.io.tmpdir="$KARAF_DATA\/tmp"/-Djava.io.tmpdir="$KARAF_BASE\/tmp"/' $JBOSS_DIR/jboss-fuse/bin/fuse && \
    sed -i -e 's/-Djava.io.tmpdir="$KARAF_DATA\/tmp"/-Djava.io.tmpdir="$KARAF_BASE\/tmp"/' $JBOSS_DIR/jboss-fuse/bin/client && \
    sed -i -e 's/-Djava.io.tmpdir="$KARAF_DATA\/tmp"/-Djava.io.tmpdir="$KARAF_BASE\/tmp"/' $JBOSS_DIR/jboss-fuse/bin/admin && \
    sed -i -e 's/${karaf.data}\/generated-bundles/${karaf.base}\/tmp\/generated-bundles/' $JBOSS_DIR/jboss-fuse/etc/org.apache.felix.fileinstall-deploy.cfg && \
    sed -i -e 's/karaf.delay.console=true/karaf.delay.console=false/' $JBOSS_DIR/jboss-fuse/etc/config.properties;


COPY users.properties $JBOSS_DIR/jboss-fuse/etc/users.properties
COPY install.sh $JBOSS_DIR/install.sh
RUN $JBOSS_DIR/install.sh

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
