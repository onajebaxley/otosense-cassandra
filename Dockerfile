## Onaje Baxley
## 6/21/18
##
## Builds the custom Cassandra 3.x (where x is "latest") Docker image,
## Replacing the original docker-entrypoint shell script with a custom one
## designed to enable Cassandra's strict authorization & authentication,
## install the Maven package manager, and inject Stratio's Lucene Index for use
## within cqlsh queries.

## Start with official Cassandra 3 image
FROM cassandra:3

## Copy Maven tar.gzip into container
COPY apache-maven-3.5.3-bin.tar.gz /home

WORKDIR /home
RUN tar -zxvf apache-maven-3.5.3-bin.tar.gz
RUN mv apache-maven-3.5.3 /opt/maven
WORKDIR /

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
ENV M2_HOME=/opt/maven
ENV PATH=${M2_HOME}/bin:${PATH}

# TODO: install git to clone lucene index
# Below block is untested
RUN apt-get upgrade
RUN apt-get install git
RUN git clone http://github.com/Stratio/cassandra-lucene-index
WORKDIR /cassandra-lucene-index
RUN git checkout 3.11.2.1
RUN mvn clean package
RUN cp /plugin/target/cassandra-lucene-index-plugin-*.jar $CASSANDRA_HOME/lib/

## Copy custom docker-entrypoint.sh into container, effectively replacing
## the default shell script that was there
COPY docker-entrypoint.sh /usr/local/bin
RUN chmod 775 /usr/local/bin/docker-entrypoint.sh

## Preserve the symlink
RUN rm /docker-entrypoint.sh
RUN ln -s usr/local/bin/docker-entrypoint.sh /docker-entrypoint.sh

## Overwrite the entrypoint
ENTRYPOINT ["docker-entrypoint.sh"]

## Pass entrypoint args (can be overwritten via "docker run")
CMD ["cassandra", "-f"]

