# Based on 10.0.1
FROM openjdk:10.0.1-jdk
MAINTAINER sami.volotinen@gmail.com

ENV WILDFLY_VERSION 13.0.0.Final
ENV WILDFLY_SHA1 3d63b72d9479fea0e3462264dd2250ccd96435f9
ENV JBOSS_HOME /opt/jboss/wildfly-13.0.0.Final
ENV JBOSS_INSTALL /opt/jboss
ENV postgres_module_dir=/opt/jboss/wildfly-13.0.0.Final/modules/system/layers/base/org/postgres/main
ENV eclipse_module_dir=/opt/jboss/wildfly-13.0.0.Final/modules/system/layers/base/org/eclipse/persistence/main
ENV config_dir=/opt/jboss/wildfly-13.0.0.Final/standalone/configuration/

USER root

RUN groupadd -r jboss -g 1000 && useradd -u 1000 -r -g jboss -m -d /opt/jboss -s /sbin/nologin -c "JBoss user" jboss && \
    chmod 755 /opt/jboss


# Add the WildFly distribution to /opt, and make wildfly the owner of the extracted tar content
# Make sure the distribution is available from a well-known place
RUN cd $HOME \
    && curl -O https://download.jboss.org/wildfly/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.tar.gz \
    && sha1sum wildfly-$WILDFLY_VERSION.tar.gz | grep $WILDFLY_SHA1 \
    && tar xf wildfly-$WILDFLY_VERSION.tar.gz \
    && mv $HOME/wildfly-$WILDFLY_VERSION $JBOSS_INSTALL \
    && rm wildfly-$WILDFLY_VERSION.tar.gz \
    && chown -R jboss:0 ${JBOSS_INSTALL} \
    && chmod -R g+rw ${JBOSS_INSTALL}

# add module.xml file
RUN mkdir -p ${postgres_module_dir}
ADD module.xml ${postgres_module_dir}
WORKDIR ${postgres_module_dir}
ADD postgresql-42.2.2.jar ${postgres_module_dir}

WORKDIR ${eclipse_module_dir}
ADD main/ ${eclipse_module_dir}

COPY standalone-ee8.xml ${config_dir}

# Ensure signals are forwarded to the JVM process correctly for graceful shutdown

ENV LAUNCH_JBOSS_IN_BACKGROUND true

USER jboss

# Allow mgmt console access to "root" group
RUN rmdir /opt/jboss/wildfly-13.0.0.Final/standalone/tmp/auth && \
    mkdir -p /opt/jboss/wildfly-13.0.0.Final/standalone/tmp/auth && \
    chmod 775 /opt/jboss/wildfly-13.0.0.Final/standalone/tmp/auth

# Expose the ports we're interested in
EXPOSE 8080
EXPOSE 9990

# Set the default command to run on boot
# This will boot WildFly in the standalone mode and bind to all interface
CMD ["/opt/jboss/wildfly-13.0.0.Final/bin/standalone.sh", "-c", "standalone-ee8.xml", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0"]

