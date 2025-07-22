---
title: "Serving Up Network Storage"
date: 2023-05-25T09:18:20-03:00
draft: false
---

One of the best features about having a server is the ability to share storage with client systems - a Network File System (NFS).  This is useful in many different enterprise computing scenarios - some really common examples include user home directories in an LDAP system, or application accessing data in shared storage, or many servers writing logs to one central location.  The use cases are really endless, and luckily, setting up a network share is remarkably easy.

> This article only covers setting up a share, see [Accessing Network Storage]({{< ref "accessingNetworkStorage.md" >}}) for details on how to access the storage from a client.

Of course, the prerequisite to this activity is having `root` access - which is why this falls under the "EveryDay Admin" section.

## Step 1: Install the NFS Server Package

NFS require the addition of an NFS service to the server.  Depending on the Linux family, the commands are slightly different:

``` bash
dnf install nfs-utils # RHEL Family
apt install nfs-kernel-server # Debian Family
```

## Step 2: Create an Export Listing
The export listing itself defines which directories should be shared.  It is very unlikely that the entire system will be shared, the much more common scenario is to create a shared space such as `/share`, which may or may not be mounted on an entirely different storage unit (see [Adding Storage to Linux]({{< ref "addingStorageToLinux.md" >}}) and [Logical Volume Management Basics]({{< ref "lvmBasics.md" >}}) for more info).

The export listing is defined in `/etc/exports`, a sample will look like this:
``` bash
/sharedSpace *(rw,no_root_squash)
/sharedLogs *(rw, no_root_squash)
``` 

## Step 3: Enable the Service and Adjust Permissions

Depending on the Linux family, the service that needs to be enabled is slightly different:
``` bash
systemctl enable --now nfs-server # RHEL Family
systemctl enable --now nfs-kernel-server # Debian Family
```

### Firewalld Specific Configuration

If you're running the  `firewalld.service`, you'll also need to adjust the firewall using these commands:
``` bash
firewall-cmd --add-service=nfs
firewall-cmd --add-service=rpc-bind
firewall-cmd --add-service=mountd
firewall-cmd --runtime-to-permanent
```

## Step 4: Validate with a Client System

To validate on a client system if the NFS is available, simply search for it using:
``` bash
# showmount -e <Name_of_NFS_Server> or <IP_of_NFS_Server>
showmount -e homeServer # OR
showmount -e 192.168.250.250
```

The result should resemble:
``` bash
Export list for homeServer:
/sharedSpace *
/sharedLogs *
```
> See [Accessing Network Storage]({{< ref "accessingNetworkStorage.md" >}}) for details on how to access the storage from a client. 
