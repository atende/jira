# Running Behind a Proxy

The Atlassian products use Tomcat to run. That means you need to edit *server.xml*
file to configure the reverse proxy, mainly if you use SSL

To make this easy you could run this container with a environment variable called *VIRTUAL_HOST* this variable will change the tomcat server configuration
to proxy the request.

![Docker Containers](subdomains_and_docker-650x352.png)

You just need to run the container with the command:

```
docker run -d --name container_name -e VIRTUAL_HOST=software.company.com \
-e PROXY_SCHEME=https -e PROXY_PORT=443 -e PROXY_SECURED=true \
--volumes-from software\_home -p 8080 --link postgresql:db atende/software
```

Change the names for the ones applicable. This feature is shared by the atlassian
containers provided by Atende Tecnology, therefore you need to change
*atende/software* with the container you want run.

In this example we are setting the VIRTUAL_HOST to **software.company.com** and
using SSL. In cases where you need SSL you **MUST** configure **PROXY_SCHEME**
to *https*, **PROXY_PORT** to *443* (or other you proxy use) and **PROXY_SECURED**
to *true*. The defaults are respectively: *http*, *80*, *false*

To create the proxy we high recommend the use of
[nginx-proxy](https://registry.hub.docker.com/u/jwilder/nginx-proxy/) container
because it will do a little of magic and configure the proxy automatically when
the container starts.

The *nginx-proxy* container works by listen to docker events to know if a container
start or stop, them it will inspect the container for the **VIRTUAL_HOST**
environment variable and create the proxy configuration automagically ;-)

The *nginx-proxy* defaults are not sufficient to run Atlassian applications. There are two things you will have to configure:

* client_max_body_size
* proxy_send_timeout
* proxy_read_timeout
* send_timeout

That is because the post size in nginx is too small for upload of files, and the timeout as well. The timeout cause some operations like
backup and restore to timeout in proxy before they actually fail in the application.

For that reason a docker image was created to customize this properties:
**atende/nginx-proxy**, it just alter de defaults with:

    server_tokens off;
    client_max_body_size 200m;
    proxy_send_timeout 300;
    proxy_read_timeout 300;
    send_timeout 300;


As a example:

```
docker run -d --name nginx -p 80:80 -p 443:443 -v \
/var/run/docker.sock:/tmp/docker.sock -v /opt/certs:/etc/nginx/certs -t atende/nginx-proxy

docker run -d --name container_name -e VIRTUAL_HOST=software.company.com \
-e PROXY_SCHEME=https -e PROXY_PORT=443 -e PROXY_SECURED=true \
--volumes-from jira\_home -p 8080 --link postgresql:db atende/software
```

Now you just need to put your certification in */opt/certs* with the names
*software.company.com.crt* and *software.company.com.key* and point you DNS to
the nginx instance (the docker host).

Now every application that needs to run behind the proxy just need the VIRTUAL_HOST variable.

If you want to know how to configure the container by hand see the documentation
in https://confluence.atlassian.com/display/JIRAKB/Integrating+JIRA+with+nginx
and https://confluence.atlassian.com/display/JIRA/Integrating+JIRA+with+Apache

See more options for the proxy in the project page
https://registry.hub.docker.com/u/jwilder/nginx-proxy/
