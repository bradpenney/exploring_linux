# Serving Up Network Storage
One of the coolest perks of running a server is sharing storage across your
network. Enter NFS (Network File System) — a way to let client machines access
storage as if it were local.

Why is this handy? A few classic use cases:
- Centralized home directories (often paired with LDAP)
- Applications needing a shared data store
- Multiple servers writing logs to one place

Honestly, the use cases are endless — and the setup is refreshingly simple.

??? info "Server-Side NFS Setup"

    This article covers setting up the server side. See
    [Accessing Network Storage](accessing_network_storage.md) for how to mount
    NFS shares on clients.  ⚠️ You’ll need `root` for all of this. Storage and
    networking are not “normal user” territory.

## Step 1: Install the NFS Server Package

First, add the NFS service. Package names differ by distro:

``` bash title="Install NFS Server Package"
dnf install nfs-utils # RHEL Family
apt install nfs-kernel-server # Debian Family
```

## Step 2: Create an Export Listing
Exports tell NFS which directories you want to share. You almost never share
the whole filesystem — it’s much safer (and saner) to create a dedicated
share, e.g. `/share` or `/logs`.

Edit `/etc/exports` and define your shares:

``` bash title="Sample /etc/exports File"
/sharedSpace *(rw,no_root_squash)
/sharedLogs *(rw, no_root_squash)
```

- `rw` → read/write
- `no_root_squash` → allows client `root` to act as `root` on the share
   (use with caution!)

## Step 3: Enable the Service and Adjust Permissions
Turn on the NFS service:

``` bash title="Enable NFS Service"
systemctl enable --now nfs-server # RHEL Family
systemctl enable --now nfs-kernel-server # Debian Family
```

If you’re running firewalld, allow NFS-related services:

``` bash title="Adjust Firewall for NFS"
firewall-cmd --add-service=nfs
firewall-cmd --add-service=rpc-bind
firewall-cmd --add-service=mountd
firewall-cmd --runtime-to-permanent
```

## Step 4: Validate with a Client System
On a client system, check that the server is actually exporting its shares:

``` bash title="Find an NFS Share"
# showmount -e <Name_of_NFS_Server> or <IP_of_NFS_Server>
showmount -e homeServer # OR
showmount -e 192.168.250.250
```

Expected output looks like this:

``` bash title="Sample Output from showmount"
Export list for homeServer:
/sharedSpace *
/sharedLogs *
```

## Enterprise Best Practices for NFS
A basic NFS setup works fine at home or in a lab, but in Production you’ll
want to tighten things up. Here are some smart defaults:

### Use `root_squash` (not `no_root_squash`)
- By default, NFS maps remote `root` users to a harmless local user (usually `nfsnobody`).
- This prevents a compromised client from owning your NFS server.
- Only use `no_root_squash` for very specific, controlled use cases.

### Restrict access by host or subnet
- Instead of `*` (any host), use IPs or CIDR blocks:

``` bash title="Restrict NFS Access by Subnet"
/sharedSpace 192.168.250.0/24(rw,sync,root_squash)
```

### Enable `sync` writes
- Forces writes to hit disk before returning “success.”
- Safer (though slower) than `async`.

### Set appropriate filesystem permissions
- NFS exports *don’t override* Linux permissions.
- Make sure your shared directories have correct ownership and mode bits.

### Watch SELinux
- On RHEL-family systems, SELinux may block NFS exports by default.
- Enable with:

``` bash title="Enable NFS in SELinux"
setsebool -P nfs_export_all_rw 1
```

### Monitor with `showmount` and `exportfs`
- `exportfs -v` shows exactly what’s being shared and with what options.
- Run it after changes to confirm settings are live.

### Consider NFSv4
- Newer, cleaner protocol with better performance and security.
- Reduces port juggling (everything runs over TCP/2049).

Bottom line: **keep it tight**. Don’t export wide-open shares unless you’re
in a safe lab environment.
