---
title: "Linux Filesystem Hierarchy"
date: 2023-03-15T10:14:19-03:00
draft: false 
---

If you've been around Linux for any time at all, you'll start to notice that completely different distributions have a similar file structure "under-the-hood".  Even UNIX systems, such as IBM's proprietary AIX operating system, has a similar file structure to standard Linux distributions.  

The reason?  The [Linux File Hierarchy Standard](https://refspecs.linuxfoundation.org/FHS_3.0/fhs/index.html) - maintained by the Linux Foundation - defines standard directories that should be found within a Linux system.  There is some flexibility, particularly in placement of files within the directories, but for the most part all compliant Linux distributions will have this structure:

``` shell

root@localhost /]# ls -ltr
total 20
drwxr-xr-x.   1 root root    0 Aug  9  2022 srv
lrwxrwxrwx.   1 root root    8 Aug  9  2022 sbin -> usr/sbin
drwxr-xr-x.   1 root root    0 Aug  9  2022 opt
drwxr-xr-x.   1 root root    0 Aug  9  2022 mnt
drwxr-xr-x.   1 root root    0 Aug  9  2022 media
lrwxrwxrwx.   1 root root    9 Aug  9  2022 lib64 -> usr/lib64
lrwxrwxrwx.   1 root root    7 Aug  9  2022 lib -> usr/lib
lrwxrwxrwx.   1 root root    7 Aug  9  2022 bin -> usr/bin
dr-xr-xr-x.   1 root root    0 Aug  9  2022 afs
drwx------.   1 root root    0 Nov  5 05:14 lost+found
drwxr-xr-x.   1 root root  168 Nov  5 05:21 usr
drwxr-xr-x.   1 root root  194 Nov  5 05:28 var
dr-xr-xr-x.   6 root root 4096 Mar  9 20:07 boot
drwxr-xr-x.   1 root root    8 Mar  9 20:07 home
drwxr-xr-x.   1 root root 5000 Mar  9 20:10 etc
dr-xr-x---.   1 root root  208 Mar  9 20:10 root
dr-xr-xr-x. 291 root root    0 Mar 23 09:35 proc
dr-xr-xr-x.  13 root root    0 Mar 23 09:35 sys
drwxr-xr-x.  20 root root 3980 Mar 23 09:35 dev
drwxr-xr-x.  56 root root 1520 Mar 23 09:35 run
drwxrwxrwt.  18 root root  420 Mar 23 09:35 tmp
[root@localhost /]# 

```

As Linux is a self-documenting operating system (see [Finding Help in Linux]({{< ref "findingHelpInLinux.md" >}})), predictably there is a lovely Manual page that explains the file system hierarchy - issue `man hier` on any distribution, read, learn and enjoy!

## Ephemeral vs Persistent File Systems and Directories

It is worth noting that not everything seen in the above listing represents a file or directory stored on a hard drive.  In particular, `/proc` and `/run` (and sometimes `/tmp`) are "ephemeral" directories mounted on RAM-based file systems.  This means they are generated during the boot process and only exist during this session.  If you were able to access this hard drive without booting the operating system (common if there are multiple hard-disks), `/proc` and `/run` would not be present on this disk.

This means that modifying anything in these directories (modifying `/run` is more common and less risky than modifying `/proc`) will only persist for the lifetime of the session.  If the system reboots, the changes are gone and set back to the defaults found by the kernel during boot procedure.

For this reason, changes that are meant to be persistent should be made in the `/etc/` directory, which will persist through reboots.
