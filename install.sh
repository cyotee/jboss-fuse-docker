#!/bin/bash
#
# We configure the distro, here before it gets imported into docker
# to reduce the number of UFS layers that are needed for the Docker container.
#

# Adjust the following env vars if needed.
FUSE_ARTIFACT_ID=jboss-fuse-karaf-full
echo "Set EV FUSE_ARTIFACT_ID to ${FUSE_ARTIFACT_ID}"
FUSE_VERSION=6.2.0.redhat-099
echo "Set EV FUSE_VERSION to ${FUSE_VERSION}"
FUSE_DISTRO_URL=http://origin-repository.jboss.org/nexus/content/groups/ea/org/jboss/fuse/${FUSE_ARTIFACT_ID}/${FUSE_VERSION}/${FUSE_ARTIFACT_ID}-${FUSE_VERSION}.zip
echo "Set EV FUSE_DISTRO_URL to ${FUSE_DISTRO_URL}"
FUSE_ARTIFACT_ID_FOR_DOCKER=jboss-fuse.tar.gz
echo "Set EV FUSE_ARTIFACT_ID_FOR_DOCKER to ${FUSE_ARTIFACT_ID_FOR_DOCKER}"
echo "FUSE_ARTIFACT_ID_FOR_DOCKER EV successfully inherited as ${FUSE_ARTIFACT_ID_FOR_DOCKER}"

# Lets fail fast if any command in this script does succeed.
set -e

# Download and extract the distro
echo "Downloading ${FUSE_ARTIFACT_ID} version ${FUSE_VERSION}"
curl -O ${FUSE_DISTRO_URL}
echo "Downloaded ${FUSE_ARTIFACT_ID} version ${FUSE_VERSION}"
#jar -xvf ${FUSE_ARTIFACT_ID}-${FUSE_VERSION}.zip
echo "Extracting ${FUSE_ARTIFACT_ID}-${FUSE_VERSION}.zip"
unzip ${FUSE_ARTIFACT_ID}-${FUSE_VERSION}.zip
echo "Deleting downloaded artifact ${FUSE_ARTIFACT_ID}-${FUSE_VERSION}.zip"
rm ${FUSE_ARTIFACT_ID}-${FUSE_VERSION}.zip
echo "Moving extracted distribution to generalized path."
mv jboss-fuse-${FUSE_VERSION} jboss-fuse
echo "Making Fuse binaries executable."
chmod a+x jboss-fuse/bin/*
echo "Deleting unneeded binaries."
rm jboss-fuse/bin/*.bat jboss-fuse/bin/start jboss-fuse/bin/stop jboss-fuse/bin/status jboss-fuse/bin/patch

# Lets remove some bits of the distro which just add extra weight in a docker image.
echo "Deleting distributed artifacts unneeded for production usage."
rm -rf jboss-fuse/extras
rm -rf jboss-fuse/quickstarts

#
# Let the karaf container name/id come from setting the FUSE_KARAF_NAME && FUSE_RUNTIME_ID env vars
# default to using the container hostname.
echo "Editing jboss-fuse/etc/system.properties file."
sed -i -e 's/environment.prefix=FABRIC8_/environment.prefix=FUSE_/' jboss-fuse/etc/system.properties
sed -i -e '/karaf.name = root/d' jboss-fuse/etc/system.properties
sed -i -e '/runtime.id=/d' jboss-fuse/etc/system.properties

echo "Editing jboss-fuse/bin/setenv file."
echo '
if [ -z "$FUSE_KARAF_NAME" ]; then
  export FUSE_KARAF_NAME="$HOSTNAME"
fi
if [ -z "$FUSE_RUNTIME_ID" ]; then
  export FUSE_RUNTIME_ID="$FUSE_KARAF_NAME"
fi
export KARAF_OPTS="-Dkaraf.name=${FUSE_KARAF_NAME} -Druntime.id=${FUSE_RUNTIME_ID}"
'>> jboss-fuse/bin/setenv

#
# Move the bundle cache and tmp directories outside of the data dir so it's not persisted between container runs
#
echo "Moving jboss-fuse/data/tmp to jboss-fuse/tmp."
mv jboss-fuse/data/tmp jboss-fuse/tmp

echo "Configuring Fuse cache location setting."
echo '
org.osgi.framework.storage=${karaf.base}/tmp/cache
'>> jboss-fuse/etc/config.properties

sed -i -e 's/-Djava.io.tmpdir="$KARAF_DATA\/tmp"/-Djava.io.tmpdir="$KARAF_BASE\/tmp"/' jboss-fuse/bin/karaf
sed -i -e 's/-Djava.io.tmpdir="$KARAF_DATA\/tmp"/-Djava.io.tmpdir="$KARAF_BASE\/tmp"/' jboss-fuse/bin/fuse
sed -i -e 's/-Djava.io.tmpdir="$KARAF_DATA\/tmp"/-Djava.io.tmpdir="$KARAF_BASE\/tmp"/' jboss-fuse/bin/client
sed -i -e 's/-Djava.io.tmpdir="$KARAF_DATA\/tmp"/-Djava.io.tmpdir="$KARAF_BASE\/tmp"/' jboss-fuse/bin/admin
sed -i -e 's/${karaf.data}\/generated-bundles/${karaf.base}\/tmp\/generated-bundles/' jboss-fuse/etc/org.apache.felix.fileinstall-deploy.cfg

# lets remove the karaf.delay.console=true to disable the progress bar
# Already default
echo "Disabling console progress bar in config.properties."
sed -i -e 's/karaf.delay.console=true/karaf.delay.console=false/' jboss-fuse/etc/config.properties

echo "Configuring console logging."
echo '
# Root logger
log4j.rootLogger=INFO, stdout, osgi:*VmLogAppender
log4j.throwableRenderer=org.apache.log4j.OsgiThrowableRenderer

# CONSOLE appender not used by default
log4j.appender.stdout=org.apache.log4j.ConsoleAppender
log4j.appender.stdout.layout=org.apache.log4j.PatternLayout
log4j.appender.stdout.layout.ConversionPattern=%d{ABSOLUTE} | %-5.5p | %-16.16t | %-32.32c{1} | %X{bundle.id} - %X{bundle.name} - %X{bundle.version} | %m%n
' > jboss-fuse/etc/org.ops4j.pax.logging.cfg

echo "Setting Fuse to bind to all available interfaces."
echo '
bind.address=0.0.0.0
'>> jboss-fuse/etc/system.properties
echo 'admin=password,Operator, Maintainer, Deployer, Auditor, Administrator, SuperUser' >> jboss-fuse/etc/users.properties
echo 'dev=password,Operator, Maintainer, Deployer' >> jboss-fuse/etc/users.properties

mkdir /opt/jboss/jboss-fuse/instances

echo "Packaging prepared server for use by Docker with command: tar -zcvf ${FUSE_ARTIFACT_ID_FOR_DOCKER} ./jboss-fuse -C `pwd`"
#tar -zcvf ${FUSE_ARTIFACT_ID_FOR_DOCKER} ./jboss-fuse -C `pwd`

echo "Removing build artifacts."
echo "Deleting ${FUSE_ARTIFACT_ID}-${FUSE_VERSION}.zip"
rm -f ${FUSE_ARTIFACT_ID}-${FUSE_VERSION}.zip
#chown -R fuse:fuse /opt/jboss/jboss-fuse
##echo "Deleting ./jboss-fuse."
##rm -rf ./jboss-fuse
