# Atlassian Crowd

[Crowd](http://www.atlassian.com/software/crowd) is a Single Single On software
created by [Atlassian](http://www.atlassian.com). With this software you could
provide a single point of authetication to all the Atlassian software and to third part one.

Users can come from Active Directory, LDAP, Crowd itself, or any mix. Is compatible
with Google Apps, Subversion or your own apps.

This is base on [Hbokh/docker-jira-postgresql](https://github.com/hbokh/docker-jira-postgresql)
but the installation and run process is made in a more generic way, to serve as base
for the installation of other Atlassian Products.

## Instalation

Is best practice to separate the data from the container. This instalation process
will assume this.

### 1. Create a data-only container for Crowd

Create a data-only container from Busybox (very small footprint) and name it "crowd\_datastore":

    docker run -v /opt/crowd-home --name=crowd\_datastore -d busybox echo "crowd data"

**NOTE**: data-only containers don't have to run / be active to be used.

### 2. Create a PostgreSQL-container

See: [POSTGRESQL](POSTGRESQL.md)

### 3. Start the Crowd container

    docker run -d --name crowd -p 8085:8085 --link postgresql:db atende/atlassian-crowd \
    --volumes-from crowd\_datastore

## Running Behind a Proxy

In production environments is a best practice run the container on port 80 and
use a appropriated name like http://software.company.com

In this cases you could also need to run the software behind a proxy, so you can
run other applications in the same host.

This is a common feature of the atlassian images generetad by Atende Tecnology.

See the [Instructions](RUNNING_PROXY.md)
