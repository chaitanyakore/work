# Reference: https://github.com/lindycoder/prepopulated-mysql-container-example
FROM mariadb:10.3-bionic as builder

# That file does the DB initialization but also runs mysql daemon, by removing the last line it will only init
RUN ["sed", "-i", "s/exec \"$@\"/echo \"not running $@\"/", "/usr/local/bin/docker-entrypoint.sh"]

ENV MYSQL_ROOT_PASSWORD=root

COPY sql/00-db_init.sql /docker-entrypoint-initdb.d/
COPY sql/01-db_structure.sql /docker-entrypoint-initdb.d/
COPY sql/02-db_content.sql /docker-entrypoint-initdb.d/

# Need to change the datadir to something else that /var/lib/mysql because the parent docker file defines it as a volume.
# https://docs.docker.com/engine/reference/builder/#volume :
#       Changing the volume from within the Dockerfile: If any build steps change the data within the volume after
#       it has been declared, those changes will be discarded.
RUN ["/usr/local/bin/docker-entrypoint.sh", "mysqld", "--datadir", "/initialized-db", "--aria-log-dir-path", "/initialized-db"]

FROM mariadb:10.3-bionic

COPY config/contentserv.cnf /etc/mysql/conf.d/
COPY --from=builder /initialized-db /var/lib/mysql-cs

CMD ["--datadir", "/var/lib/mysql-cs"]
