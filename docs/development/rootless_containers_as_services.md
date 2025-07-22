---
title: "Running Rootless Containers as Services"
date: 2023-06-08T16:36:06-03:00
draft: false
---

When utilizing rootless containers directly on a Linux server, starting and stopping the container manually can become a major hassle, especially if other containers rely on the service.  For this reason, running containers as `systemd` services that start and stop with the underlying `systemd` controls provides significant value to developers and system administrators alike.

> Application Development on Enterprise Linux occurs largely within containerized applications.  While container orchestration platforms like Kubernetes and OpenShift (RHEL's version of Kubernetes with extra features) are often used, there is also a [use-case for running a container directly on a Linux server without orchestration](https://bradpenney.ca/devops/managecontainerswithcockpit/), often in the early-stages of development.

## Enable Linger for Specific User Account
The only part of this process that will require `root` access is to enable *linger* for the user that owns the container.  This means that even if the user is not logged in, `systemd` services associated with that user will start/stop with the server (if they are enabled).  Enabling linger is a simple one-line command:

``` bash
#loginctl enable-linger <user>
loginctl enable-linger brad
```

Now, if the user `brad` enables a `systemd` service (as per below), it will start and stop with the server startup/shutdown.

## Create a Systemd Service to Control a Rootless Container

Logged in as the linger-enabled user and with a container already running (see [Introducing Podman]({{< ref "introducingPodman.md" >}}) for an example), issue the following commands:

``` bash
mkdir ~/.config/systemd/user # create a directory to store the systemd files
cd ~/.config/systemd/user # switch to that directory
# podman generate systemd --name <ContainerName> --files
podman generate systemd --name nextCloud --files # generate the files
systemctl --user daemon-reload # make the systemd service aware of the files
```
Starting and stopping the container should now be done with `systemctl --user start <containerName>.serivice`, `systemctl --user stop <containerName>.service`, or simply check the status with `systemctl --user status <containerName>.servicei`.  For example, running `systemctl --user status container-nextcloud.service` results in:

![NextCloud Rootless Container as a Service]({{< siteurl >}}/images/nextcloud_service.png) 

## Enable the Systemd Service to Run at System Startup

Now that the container is controlled by a `systemd` service, it can be enabled in a similar way as any other `systemd` service. The only caveat is to remember to add the `--user` flag as it is a user service, not a system service:

``` bash
# systemctl --user enable <container-ContainerName.service>
systemctl --user enable container-nextcloud.service
``` 
> Find the name of the container serve in `~/.config/systemd/user/` directory if necessary.

Rebooting the server should now result in the container starting automatically.  This can be validated with a simple `ps -ef | grep nextcloud` or `podman ps | grep nextcloud`.  

> Depending on the application setup, it may be necessary to repeat this process and even edit the `systemd` service files to ensure the containers start in the correct order to resolve their dependencies on each other (outside the scope of this article).  For example, the container setup in [Introducing Podman]({{< siteurl "introducingPodman.md" >}}) requires that the MariaDB container be started before the NextCloud container.

