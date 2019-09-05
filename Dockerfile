FROM debian:sid-slim

ENV JAVA_MAJOR 8
ENV JAVA_MINOR 0_221
ENV JAVA_HOME /opt/java

ENV CONF_HOME /var/atlassian/confluence
ENV CONF_INSTALL /opt/atlassian/confluence
ENV CONF_VERSION 6.15.9


COPY 	jdk1.${JAVA_MAJOR}.${JAVA_MINOR} /opt/jdk1.${JAVA_MAJOR}.${JAVA_MINOR}


RUN  ln -s /opt/jdk1.${JAVA_MAJOR}.${JAVA_MINOR} /opt/java

RUN 	apt-get update \
	&& apt-get upgrade -y \
    && apt install curl  ca-certificates -y --no-install-recommends \
	&& rm -rf /var/lib/apt/lists/*  \
	&& mkdir -p ${CONF_HOME} \
	&& mkdir -p ${CONF_INSTALL}  \
	&& curl -Ls  "https://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-${CONF_VERSION}.tar.gz" | tar -xz --directory "${CONF_INSTALL}" --strip-components=1 --no-same-owner \
	&& curl -Ls "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.45.tar.gz" | tar -xz --directory "${CONF_INSTALL}/lib" --strip-components=1 --no-same-owner "mysql-connector-java-5.1.45/mysql-connector-java-5.1.45-bin.jar" \
	&& chown -R daemon:daemon ${CONF_HOME} \
	&& chown -R daemon:daemon ${CONF_INSTALL} \
	&& echo -e  "\nconfluence.home=$CONF_HOME" >> "${CONF_INSTALL}/confluence/WEB-INF/classes/confluence-init.properties" 



# run as daemon user
USER daemon:daemon

EXPOSE 8090 8091

VOLUME ["/var/atlassian/confluence", "/opt/atlassian/confluence/logs"]

WORKDIR /var/atlassian/confluence

COPY "docker-entrypoint.sh" "/"
ENTRYPOINT ["/docker-entrypoint.sh"]

# Run Atlassian Confluence with delay to be sure MySQL is up and running 
COPY "start_confluence_delay.sh" "/"
CMD ["/start_confluence_delay.sh"]


