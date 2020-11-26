FROM ubuntu:18.04

# Set version and github repo which you want to build from
ENV DRUID_VERSION 0.20.0
ENV LOG4J_VERSION 1.2.17

# Java 8
RUN apt-get update \
      && apt-get install -y openjdk-8-jre-headless openjdk-8-jdk wget libmysql-java libpostgresql-jdbc-java

# Retrieve druid distribution
RUN mkdir -p /tmp/druid/ \
    && cd /tmp/druid \
    && wget http://apache.cs.uu.nl/druid/$DRUID_VERSION/apache-druid-$DRUID_VERSION-bin.tar.gz \
    && mkdir -p /opt/druid \
    && tar -xzvf /tmp/druid/apache-druid-$DRUID_VERSION-bin.tar.gz -C /opt/druid --strip 1 \
    && rm -rf /tmp/druid \
    && ln -s /usr/share/java/mysql-connector-java.jar /opt/druid/extensions/mysql-metadata-storage/mysql-connector-java.jar \
    && ln -s /usr/share/java/postgresql.jar /opt/druid/extensions/postgresql-metadata-storage/postgresql.jar

#missing log4j deps for integrated zk
RUN mkdir -p /tmp/log4j/ \
    && cd /tmp/log4j \
    && wget http://apache.cs.uu.nl/logging/log4j/$LOG4J_VERSION/log4j-$LOG4J_VERSION.tar.gz \
    && mkdir /opt/log4j \
    && tar -xzvf /tmp/log4j/log4j-$LOG4J_VERSION.tar.gz -C /opt/log4j --strip 1 \
    && cp /opt/log4j/log4j-1.2.17.jar /opt/druid/lib/log4j-1.2.17.jar \
    && rm -rf /tmp/log4j \
    && rm -rf /opt/log4j

# Add aliyun oss extensions

RUN cd /opt/druid/ && java \
  -cp "lib/*" \
  -Ddruid.extensions.directory="/opt/druid/extensions" \
  -Ddruid.extensions.hadoopDependenciesDir="/opt/druid/hadoop-dependencies" \
  org.apache.druid.cli.Main tools pull-deps \
  --no-default-hadoop \
  -c "org.apache.druid.extensions.contrib:aliyun-oss-extensions:$DRUID_VERSION"


  # Add statsd emitter

  RUN cd /opt/druid/ && java \
    -cp "lib/*" \
    -Ddruid.extensions.directory="/opt/druid/extensions" \
    -Ddruid.extensions.hadoopDependenciesDir="/opt/druid/hadoop-dependencies" \
    org.apache.druid.cli.Main tools pull-deps \
    --no-default-hadoop \
    -c "org.apache.druid.extensions.contrib:statsd-emitter:$DRUID_VERSION"

COPY run-zk /opt/druid/bin/run-zk

COPY jvm_config/ /opt/jvm_config

RUN chmod +x /opt/druid/bin/run-zk

RUN mkdir -p /opt/druid/var/sv

WORKDIR /

# Openned ports:
# - 8081: HTTP (coordinator)
# - 8082: HTTP (broker)
# - 8083: HTTP (historical)
# - 8091: HTTP (overlord)
# - 8888: HTTP (proxy)
# - 3306: MySQL
# - 2181 2888 3888: ZooKeeper
# Ports are not exposed so that nomad can configure them

RUN apt install -y perl

COPY docker-entrypoint.sh /

RUN chmod +x /docker-entrypoint.sh

WORKDIR /opt/druid
ENTRYPOINT ["/docker-entrypoint.sh"]
