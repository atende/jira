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

Note: If the software need to be runned in two ports, use the environment variable SECONDARY_NO_SSL_PORT=7080 this will create a secondary connector with NO SSL configuration.
The default port will not be touched. This is a workround for the bug https://jira.atlassian.com/browse/JRA-40968

## Running Behind a Proxy

In production environments is a best practice run the container on port 80 and
use a appropriated name like http://software.company.com

In this cases you could also need to run the software behind a proxy, so you can
run other applications in the same host.

This is a common feature of the atlassian images generetad by Atende Tecnology.

See the [Instructions](RUNNING_PROXY.md)

## Easy Running Everything at Once

Using [Crane](https://github.com/michaelsauter/crane) you can easy startup all containers at once respecting its dependencies. This is by far the easy way to create a environment with several atlassian tools and ready for production. Just install docker, install crane and see [crane.yml](crane.yml) file.
Change the file with your values and create the databases for each application
in the *postgresql* container and configure each application accessing it interface.

If you keep the proxy settings (see [Running behind Proxy](RUNNING_PROXY.md) for details),
it will also automatically create the proxy. Now you just need to change your DNS server

If you are migrating, restore your data in the data containers, and in the database

The startup script for crane command could be something like that:

    /usr/local/bin/crane lift -c /etc/crane.yml > /dev/null 2>&1

## Single Single On with Crowd

Atlassian applications could be configured to talk in Single Single On with Crowd software. Some applications has different configuration procedures, such as Stash, but for this that have the same procedure as Jira, that is, the configuration is created by file modifications in the tomcat instalation there is a automatic way to create such config in this container. This is important, because the docker principle is that container are disposable, and you don't want to tight couple its configuration to the container, because you need to recreate this configs each time you update a container. Unfortunnely some aspects of the configuration for atlassian products violates this principle, the proxy configuration and Single Single On are some examples.

To recreate the Single Single On config the procedure was automated for the softwares:

* Jira
* Bamboo
* Confluence
* Stash - Stash has a different procedure, but you can create the file needed, transparent

### How it works

With the same principle of proxy, environment variables are readed to create and update the files needed. This variables are:

```
CROWD_URL - URL for the crowd application, ex.: http://localhost:8085 (/crowd/services and /crowd/console will be appended)
CROWD_APPLICATION_NAME - Name of the application for authentication
CROWD_PASSWORD - Password for auth
```

When this 3 variables are seted the follow is generated:

1. File _WEB-INF/classes/seraph-config.xml_ is updated according with the documentation of each application, it is, the **<authenticator>** tag is replaced
2. File _WEB-INF/classes/crowd.properties file is created
3. For stash the file **stash-home/shared/stash-config.properties** is replaced or created with a the content **"plugin.auth-crowd.sso.enabled=true"**

You will need to prepare and configure each application before the change, read: https://confluence.atlassian.com/display/CROWD/Adding+an+Application for details.

If you application is alread running, stops, remove and run again with the variables. If you follow the instalation process that separate application data and postgresql you will lose nothing.

This feature was added after the first tags in github, so, if the readme do not contain this instruction only the latest release have that.
