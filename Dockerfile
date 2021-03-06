FROM fedora:23

# MySQL image for OpenShift.
#
# Volumes:
#  * /var/lib/mysql/data - Datastore for MySQL
# Environment:
#  * $MYSQL_USER - Database user name
#  * $MYSQL_PASSWORD - User's password
#  * $MYSQL_DATABASE - Name of the database to create
#  * $MYSQL_ROOT_PASSWORD (Optional) - Password for the 'root' MySQL account

MAINTAINER http://fedoraproject.org/wiki/Cloud

ENV MYSQL_VERSION=5.6 \
    HOME=/var/lib/mysql

LABEL io.k8s.description="MySQL is a multi-user, multi-threaded SQL database server" \
      io.k8s.display-name="MySQL 5.6" \
      io.openshift.expose-services="3306:mysql" \
      io.openshift.tags="database,mysql,mysql56,rh-mysql56"

EXPOSE 3306

# This image must forever use UID 27 for mysql user so our volumes are
# safe in the future. This should *never* change, the last test is there
# to make sure of that.
RUN yum -y --setopt=tsflags=nodocs install gettext hostname bind-utils community-mysql-server && \
    yum clean all && \
    mkdir -p /var/lib/mysql/data && chown -R mysql.0 /var/lib/mysql && \
    test "$(id mysql)" = "uid=27(mysql) gid=27(mysql) groups=27(mysql)"

# Get prefix path and path to scripts rather than hard-code them in scripts
ENV CONTAINER_SCRIPTS_PATH=/usr/share/container-scripts/mysql \
    MYSQL_PREFIX=/usr \
    ENABLED_COLLECTIONS=

ADD root /

# this is needed due to issues with squash
# when this directory gets rm'd by the container-setup
# script.
RUN rm -rf /etc/my.cnf.d/* 
RUN /usr/libexec/container-setup

VOLUME ["/var/lib/mysql/data"]

USER 27

ENTRYPOINT ["container-entrypoint"]
CMD ["run-mysqld"]
