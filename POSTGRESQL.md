# Installing Postgresql

Create a data-only container from Busybox (very small footprint) and name
it "pgsql\_data":

    docker run -v /data --name=pgsql_data -d busybox echo "pgsql data"

You could use any image you what, but I made one that is derivated from
*paintedfox/postgresql* and make some bugs corrections

    docker run -d --name=postgresql -e USER="super" -e DB="software_db" -e PASS="p4ssw0rd" \
    --volumes-from pgsql\_data atende/postgresql

This will create a postgresql container and the contents of the database will
be separated from the postgres instance. It will also create a user named super
with the password *p4ssw0rd* and a database named *software_db*.
Change to whatever you like. The user is a super user.

If you plan to run other applications in the same host, I recommend create the
users and databases after. That way the user will not be a database super user.
By default the postgresql container create a user called super, you can check
its random password with the command `docker logs postgresql`.

A quick way to do that could be:

    docker exec -i -t postgresql bash # login to the container
    su postgres
    psql # login to the database
    create role software_user with login;
    alter user software_user with encrypted password 'p4ssw0rd';
    create database software_db owner software_user;
