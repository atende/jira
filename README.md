# Atlassian Jira

JIRA is the tracker for teams planning and building great products. Thousands of teams choose JIRA to capture and organize issues, assign work, and follow team activity. At your desk or on the go with the new mobile interface, JIRA helps your team get the job done.

This is inspired by [Hbokh/docker-jira-postgresql](https://github.com/hbokh/docker-jira-postgresql)
but the installation and run process is made in a more generic way, to serve as base
for the installation of other Atlassian Products.

## Instalation

Is best practice to separate the data from the container. This instalation process
will assume this.

### 1. Create a data-only container for jira

Create a data-only container from Busybox (very small footprint) and name it "jira\_datastore":

    docker run -v /opt/crowd-home --name=jira\_datastore -d busybox echo "jira data"

**NOTE**: data-only containers don't have to run / be active to be used.

### 2. Create a PostgreSQL-container

See: [POSTGRESQL](POSTGRESQL.md)

### 3. Start the Software container

    docker run -d --name jira -p 8080:8080 --link postgresql:db atende/jira \
    --volumes-from jira\_datastore

## Running Behind a Proxy

In production environments is a best practice run the container on port 80 and
use a appropriated name like http://software.company.com

In this cases you could also need to run the software behind a proxy, so you can
run other applications in the same host.

This is a common feature of the atlassian images generetad by Atende Tecnology.

See the [Instructions](RUNNING_PROXY.md)
