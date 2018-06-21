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

## Copy custom docker-entrypoint.sh into container, effectively replacing
## the default shell script that was there
COPY docker-entrypoint.sh /usr/local/bin

## Preserve the symlink
RUN ln -s usr/local/bin/docker-entrypoint.sh /docker-entrypoint.sh

## Overwrite the entrypoint
ENTRYPOINT ["docker-entrypoint.sh"]

## Pass entrypoint args (can be overwritten via "docker run")
CMD ["cassandra", "-f"]

