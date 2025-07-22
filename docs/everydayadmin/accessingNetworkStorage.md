---
title: "Accessing Network Storage"
date: 2023-05-25T09:33:56-03:00
draft: false
---

A key component of enterprise computing is sharing of data and information between computers.  Network Files Systems (NFS) allow client systems to draw on or add to information stored on servers - this has a variety of use cases such as applications writing logs, sharing data from a database, or user home directories.  Whatever the use case, NFS makes many everyday administration tasks easier.

> This article will cover accessing an NFS that is already shared out from the server.  See  [Serving Up Network Storage]({{< ref "networkFileShareServer.md" >}}) for details on how to set up the share drive.

## Finding an NFS Share

To locate an NFS share that is available, search for it using:
``` bash
# showmount -e <Name_of_NFS_Server> or <IP_of_NFS_Server>
showmount -e homeServer # OR
showmount -e 192.168.250.250
```

The result should resemble:
``` bash
Export list for homeServer:
/sharedSpace *
```

Once located, the next step is to determine the appropriate way to set up access - permanent or automount?

## Option 1: Permanently Mounted
Permanently mounted means the client system will always show the NFS system in its  [File System Hierarchy]({{< ref "linuxFilesystemHierarchy.md" >}}).  This approach makes a lot of sense in many enterprise systems - it is desirable to always be able to see a target directory as if it were part of the client system.  There is one major drawback however - if the NFS server is unavailable, it may cause instability in the client.  Specifically, the client may boot very slowly (due to timeouts) or may not boot at all.  However, if the NFS server is meant to have 99.999% availability (the gold standard in enterprise computing), this shouldn't be an issue.

The software needed to access a permanently mounted NFS share depends on the Linux family:

``` bash
dnf install nfs-utils # RHEL Family
apt install nfs-common # Debian Family
```

To permanently mount an NFS, it needs to be added to `/etc/fstab`.  Start by making a backup (`cp /etc/fstab /etc/fstab_bkup`), then add the following line to `/etc/fstab`:

``` bash
# <NFS_Server_Name>:/<share_name>   /<mountPoint>   nfs     sync    0 0
homeServer:/                        /share          nfs     sync    0 0
```

Once this is done, standard validations include:
``` bash
mount -a # check if error thrown
mount | grep homeServer # should return some lines
findmnt --verify # should return no issues
```

If these validations succeed, a final reboot should confirm the NFS is now working correctly.

## Option 2: Automount
 
Automount is an interesting option that also makes sense in the right scenario.  For instance, if user home directories are actually located on an NFS and not on the client computer, then having them permanently mounted isn't desirable from either a privacy or security standpoint. It would make more sense for a logged in user should see their particular home directory (on-demand as needed) and nothing else.  Another example scenario would be logging - if a server only writes to a log once per day and that log is stored in an NFS, there is no reason for the OS to maintain connectivity to the NFS for the other 23 hours per day.  The beauty is that the file system is available *seamlessly on-demand* whenever called upon by a user or program, but disconnects  when not in use (default timeout is configurable).  

> Note that automounting usually makes sense when directory access is programmatically defined (via script or program).  For instance, as soon as a user logs in via SSH, `/etc/profile` defines their home directory.  The end-user doesn't need to know whether it is an NFS or not (and almost certainly doesn't care).

The software for automounting is different than permanently mounting an NFS:
``` bash
dnf install autofs # RHEL Family
apt install autofs # Debian Family

# Enable the service
systemctl enable --now autofs
```

> Remember to restart the `autofs.service` every time the configuration files are changed - `systemctl restart autofs`

### Define Mounts

Automounting requires  (at least) two different files:

1. `/etc/auto.master` - defines the mount point and the secondary file that it configures 
2. `/etc/auto.<shortName>` - as defined in the `auto.master` file, these files configure each share

A different configuration file is used for each share, so `/etc/master` may have many entries, each with a corresponding `/etc/auto.<shortName>` configuration file.

### A Working Example
This might be best illustrated with a working example. In a sample system, simply add the following lines to the bottom of the `/etc/auto.master` file (which may contain some auto-generated content, but is not subject to being overwritten by system updates).  An example might be:

``` bash
# /etc/auto.master
# /<mountPoint> /etc/auto.<configFile>
/share  /etc/auto.share
```

The corresponding `/etc/auto.share` configuration file would contain:

``` bash
# /etc/auto.share
# <wildcard> <read/write> <location>
*   -rw     homeServer:/sharedSpace/&
```

#### Explanation
In the above example, `homeServer` is serving up `/sharedSpace`, meaning all the subdirectories within it can be accessed.  When using automount, an end-user navigating through the CLI won't see any subdirectories there, but could access them if the file paths were known (i.e. `/share/backups`).  This is why, as noted above, automount is usually used in conjunction with scripting/programming.  The lack of visibility via CLI provides privacy and security, but the resources are still available as needed (and usually accessed via scripts/programs).

## Conclusion
Whether choosing to permanently mount or automount NFS storage, it is a critical component of enterprise computing and administrators should be comfortable with accessing network storage.  It extends the power of infrastructure and is a key component in enterprise-grade server administration.

> In case you missed it above, [Serving Up Network Storage]({{< ref "networkFileShareServer.md" >}}) contains the details on how to set up the share drive.

