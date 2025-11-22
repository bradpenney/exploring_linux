# Linux Filesystem Hierarchy

If you've spent any time with Linux, you'll notice that totally different
distributions share a similar file structure "under the hood." Even UNIX
systems like IBM's AIX have a layout that's a lot like standard Linux
distros.

Why? It's thanks to the
[Linux File Hierarchy Standard](https://refspecs.linuxfoundation.org/FHS_3.0/fhs/index.html)
(FHS), maintained by the Linux Foundation. The FHS defines the standard
directories you should find on any Linux system. There's some wiggle room
in where files go inside those directories, but for the most part, all
compliant Linux distributions stick to this structure:

```shell {title="Linux Filesystem Hierarchy"}
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

Since Linux is a self-documenting operating system (see
[Finding Help in Linux](finding_help.md)), there's a
Manual page that explains the file system hierarchy. Just run `man hier`
on any distro, read, learn, and enjoy! 📚

## Ephemeral vs Persistent File Systems and Directories

Not everything in the above listing is a file or directory stored on your
hard drive. In particular, `/proc` and `/run` (and sometimes `/tmp`) are
"ephemeral" directories mounted on RAM-based file systems. They're created
during boot and only exist for your current session. If you accessed the
hard drive without booting Linux (say, from another OS), `/proc` and `/run`
wouldn't be there.

So, changes you make in these directories (modifying `/run` is more common
and less risky than `/proc`) only last until you reboot. After that, things
reset to whatever the kernel finds at boot.

If you want changes to stick around after a reboot, make them in `/etc/`.
That's where persistent configuration lives.
