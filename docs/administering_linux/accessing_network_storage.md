# Accessing Network Storage
One of the cornerstones of enterprise computing is letting systems share data
seamlessly. Enter NFS (Network File System): it lets clients pull from or write
to storage on a server as if it were local.

Classic use cases include:
- Applications writing logs to a central share
- Database servers sharing data files
- User home directories in large organizations

Whatever the use case, NFS makes life a lot easier.

??? note "Client-Side NFS Setup"

    This article covers accessing an existing NFS export. If you need to set
    up the server side first, see
    [Serving Up Network Storage](network_file_share_server.md).

## Finding an NFS Share

To see what a server is sharing, run:
``` bash title="Show NFS Exports"
# showmount -e <Name_of_NFS_Server> or <IP_of_NFS_Server>
showmount -e homeServer # OR
showmount -e 192.168.250.250
```

The result should resemble:
``` bash title="Sample NFS Export List"
Export list for homeServer:
/sharedSpace *
```

Once you know what’s available, you have two main choices for mounting it:
permanently or on-demand with automount.

## Option 1: Permanently Mounted
A permanent mount means the NFS share is always present in the
[Linux File System Hierarchy](../essential_concepts/filesystem_hierarchy.md).
To the client, it just looks like another directory.

- 👍 Pros: always there, seamless for apps and users
- 👎 Cons: if the NFS server is down, your client may hang or fail to boot

For enterprise systems with “five-nines” uptime, that tradeoff is usually fine.

### Install Client Packages

``` bash title="Install NFS Client Package"
dnf install nfs-utils # RHEL Family
apt install nfs-common # Debian Family
```

### Add to `/etc/fstab`
Always back it up first:

``` bash title="Backup /etc/fstab"
cp /etc/fstab /etc/fstab_bkup
```

Then add:

``` bash title="Edit /etc/fstab"
# <NFS_Server_Name>:/<share_name>   /<mountPoint>   nfs     sync    0 0
homeServer:/                        /share          nfs     sync    0 0
```

### Validate the Mount
``` bash
mount -a # check if error thrown
mount | grep homeServer # should return some lines
findmnt --verify # should return no issues
```

If all looks good, reboot and confirm it mounts automatically.

## Option 2: Automount
Automounting makes shares available on demand — they appear only when accessed,
and disappear when idle.

This is great for:

- User home directories (only mount them when someone logs in)
- Occasional writes (e.g., daily log dumps)
- Reducing overhead when constant connectivity isn’t needed

From a user’s perspective: it “just works” when they need it, but doesn’t
clutter the system otherwise.

### Install and enable `autofs`

``` bash
dnf install autofs # RHEL Family
apt install autofs # Debian Family

# Enable the service
systemctl enable --now autofs
```

??? warning "Restart Required After Config Changes"

    Remember: restart autofs every time you change its config:

    ``` bash title="Restart autofs"
    systemctl restart autofs
    ```

### Configure Automount
Automount uses at least two files:
- `/etc/auto.master` → defines the mount point and its map file
- `/etc/auto.<shortName>` → the specific config for that share

Example:

`/etc/auto.master`:

``` bash title="Sample /etc/auto.master"
# /etc/auto.master
# /<mountPoint> /etc/auto.<configFile>
/share  /etc/auto.share
```

`/etc/auto.share`:

``` bash title="Sample /etc/auto.share"
# /etc/auto.share
# <wildcard> <read/write> <location>
*   -rw     homeServer:/sharedSpace/&
```

### How it Works
- The server homeServer shares `/sharedSpace`.
- Clients don’t see subdirectories until they’re accessed (i.e.
`/share/backups`).

## Conclusion

Whether you go with permanent mounts or automount, NFS is a fundamental tool
for enterprise admins. It extends the filesystem across machines, making your infrastructure far more flexible and powerful.

??? note "Need the Server Side?"

    In case you missed it above,
    [Serving Up Network Storage](./network_file_share_server.md) contains the
    details on how to set up the share drive.

