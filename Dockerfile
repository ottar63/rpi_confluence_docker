FROM openjdk:8-alpine

# Configuration variables.
ENV CONF_HOME     /var/atlassian/confluence
ENV CONF_INSTALL  /opt/atlassian/confluence
ENV CONF_VERSION  6.15.7

# Install Atlassian CONFLUENCE and helper tools and setup initial home
# directory structure.
RUN set -x \
    && apk add --no-cache curl xmlstarlet bash ttf-dejavu libc6-compat \
    && mkdir -p                "${CONF_HOME}" \
    && mkdir -p                "${CONF_HOME}/caches/indexes" \
    && chmod -R 700            "${CONF_HOME}" \
    && chown -R daemon:daemon  "${CONF_HOME}" \
    && mkdir -p                "${CONF_INSTALL}/conf/Catalina" \
    && curl -Ls                "https://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-${CONF_VERSION}.tar.gz" | tar -xz --directory "${CONF_INSTALL}" --strip-components=1 --no-same-owner \
    && curl -Ls                "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.45.tar.gz" | tar -xz --directory "${CONF_INSTALL}/lib" --strip-components=1 --no-same-owner "mysql-connector-java-5.1.45/mysql-connector-java-5.1.45-bin.jar" \
    && rm -f                   "${CONF_INSTALL}/lib/postgresql-9.1-903.jdbc4-atlassian-hosted.jar" \
    && curl -Ls                "https://jdbc.postgresql.org/download/postgresql-42.2.1.jar" -o "${JIRA_INSTALL}/lib/postgresql-42.2.1.jar" \
    && chmod -R 700            "${CONF_INSTALL}/conf" \
    && chmod -R 700            "${CONF_INSTALL}/logs" \
    && chmod -R 700            "${CONF_INSTALL}/temp" \
    && chmod -R 700            "${CONF_INSTALL}/work" \
    && chown -R daemon:daemon  "${CONF_INSTALL}/conf" \
    && chown -R daemon:daemon  "${CONF_INSTALL}/logs" \
    && chown -R daemon:daemon  "${CONF_INSTALL}/temp" \
    && chown -R daemon:daemon  "${CONF_INSTALL}/work" \
    && echo -e                 "\nconfluence.home=$CONF_HOME" >> "${CONF_INSTALL}/confluence/WEB-INF/classes/confluence-init.properties" \
    && touch -d "@0"           "${CONF_INSTALL}/conf/server.xml" 
# use 32 bit version of setenv
#RUN cp   "${CONF_INSTALL}/bin/setenv32.sh" "${CONF_INSTALL}/bin/setenv.sh"
# 
#RUN echo "jira.index.batch.maxrambuffermb=256\njira.index.interactive.maxrambuffermb=256\n" >>${CONF_INSTALL}/jira-config.properties

# Use the default unprivileged account. This could be considered bad practice
# on systems where multiple processes end up being executed by 'daemon' but
# here we only ever run one process anyway.
USER daemon:daemon

# Expose default HTTP connector port.
EXPOSE 8090 8091

# Set volume mount points for installation and home directory. Changes to the
# home directory needs to be persisted as well as parts of the installation
# directory due to eg. logs.
VOLUME ["/var/atlassian/confluence", "/opt/atlassian/confluence/logs"]

# Set the default working directory as the installation directory.
WORKDIR /var/atlassian/confluence

#COPY "docker-entrypoint.sh" "/"
#ENTRYPOINT ["/docker-entrypoint.sh"]

# Run Atlassian JIRA as a foreground process by default.
CMD ["/opt/atlassian/confluence/bin/start-confluence.sh", "-fg"]
