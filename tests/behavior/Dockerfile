FROM mysql=8.4


ENV MYSQL_ROOT_PASSWORD=root
ENV MYSQL_DATABASE=sandbox
ENV MYSQL_USER=user
ENV MYSQL_PASSWORD=password


# Add schema initialization script
COPY init.sql /docker-entrypoint-initdb.d/
