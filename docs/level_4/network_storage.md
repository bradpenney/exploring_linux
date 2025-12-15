# Accessing Network Storage: NFS and autofs

!!! quote "Making remote files feel local"

## The Magic of Networked Filesystems

In many environments, data isn't stored on just one machine. You have a central file server that holds user home directories, application data, or shared resources. The magic of a **Network File System (NFS)** is that it allows your Linux machine to access those remote files *as if they were on your local disk*.

You can `cd` into a directory, `ls` its contents, and open a file, without realizing that the data is actually streaming over the network from another server.

This guide covers the two main ways to access NFS shares on a client machine:
1.  **Permanent Mounts** via `/etc/fstab` for resources that should always be available.
2.  **On-Demand Mounts** via `autofs` for resources that are only needed occasionally.

---

## Step 0: Prerequisites

### Install NFS Client Packages

Before you can mount an NFS share, you need the client-side tools.

```bash title="Install NFS client tools"
# For RHEL-family systems (CentOS, Fedora, Rocky)
sudo dnf install nfs-utils

# For Debian-family systems (Ubuntu)
sudo apt install nfs-common
```

### Discover Available Shares

You need to know the server's hostname (or IP) and the path it's exporting. You can use `showmount` to ask an NFS server what it's sharing.

```bash title="See what 'fileserver' is sharing"
showmount -e fileserver
```
**Output:**
```
Export list for fileserver:
/exports/data  *
/exports/home  192.168.1.0/24
```
This tells us the server `fileserver` is exporting two directories: `/exports/data` to everyone (`*`) and `/exports/home` to a specific subnet.

---

## Option 1: The Permanent Mount (`/etc/fstab`)

This is the classic method. You add an entry to `/etc/fstab`, and the network share is mounted automatically at boot. It will always be there, just like a local disk.

**Best for:**
-   Always-on, critical resources.
-   Application data directories.
-   Shared resources that are core to the system's function.

### Step 1: Create a Mount Point

This is the empty local directory where the remote files will appear.

```bash
sudo mkdir /data
```

### Step 2: Edit `/etc/fstab`

First, **always back up fstab before editing!**
```bash
sudo cp /etc/fstab /etc/fstab.bak
```

Now, open `/etc/fstab` with a text editor (`sudo nano /etc/fstab`) and add a line at the end.

**The format:**
`[server]:/[remote_path]  [local_mount_point]  nfs  [options]  0 0`

```
# Example fstab entry
fileserver:/exports/data   /data   nfs   defaults,_netdev,sync   0   0
```

**Key Options for NFS:**
-   `defaults`: A standard set of options.
-   `_netdev`: **Crucial.** This tells the system "this is a network device, don't try to mount it until the network is up." This prevents boot delays and errors.
-   `sync`: Forces writes to be synchronous. Slower but safer for data integrity.
-   `auto`: Mount automatically at boot (this is part of `defaults`).

### Step 3: Mount and Verify

Tell the system to mount everything in `/etc/fstab` that isn't already mounted.
```bash
sudo mount -a
```
If this command returns no errors, your fstab entry is likely correct.

Now, verify with `df -h`.
```bash
df -h
```
**Output:**
```
Filesystem                 Size  Used Avail Use% Mounted on
...
fileserver:/exports/data   1.8T  1.2T  600G  67% /data
```
You can see the remote filesystem is now mounted on `/data`. Any file operations in `/data` are now happening on the `fileserver`.

---

## Option 2: The On-Demand Mount (`autofs`)

`autofs` is a clever service that mounts filesystems only when they are accessed. After a period of inactivity, it automatically unmounts them.

**Best for:**
-   User home directories on a multi-user system.
-   Shares that are only needed occasionally.
-   Preventing system hangs if a network resource is temporarily unavailable.

### Step 1: Install and Enable `autofs`

```bash title="Install and enable autofs service"
# RHEL-family
sudo dnf install autofs
# Debian-family
sudo apt install autofs

# Enable and start the service
sudo systemctl enable --now autofs
```

### Step 2: Configure the Master Map

`autofs` is controlled by a master map file, `/etc/auto.master`. This file tells `autofs` where to look for more specific map files.

Open it (`sudo nano /etc/auto.master`) and add a line:
```
# [mount_base]   [map_file]      [options]
/nfs             /etc/auto.nfs   --timeout=60
```
-   `/nfs`: This is the base directory where mounts will appear.
-   `/etc/auto.nfs`: This is the map file that defines what to mount inside `/nfs`.
-   `--timeout=60`: Unmount a share after 60 seconds of inactivity.

### Step 3: Configure the Specific Map

Now, create the map file `/etc/auto.nfs` (`sudo nano /etc/auto.nfs`).

This file defines the on-demand mounts.
```
# [mount_name]  [mount_options]  [server:/remote/path]
data            -rw,sync         fileserver:/exports/data
home            -rw,sync         fileserver:/exports/home
```
- `data`: The name of the subdirectory that will appear under `/nfs`.
- `-rw,sync`: Mount options (read-write, synchronous).
- `fileserver:/exports/data`: The remote NFS share.

### Step 4: Restart and Verify

Reload the `autofs` service to apply the changes.
```bash
sudo systemctl restart autofs
```
Now, try to access one of the on-demand shares:
```bash
ls /nfs/data
```
The first time you access it, there will be a slight pause as `autofs` mounts it in the background. Then, you'll see the contents of `fileserver:/exports/data`. If you wait 60 seconds without accessing it, it will automatically unmount.

## Troubleshooting Common NFS Issues

**Mount command hangs or times out.**
-   **Firewall:** The most common issue. Ensure the client is allowed to connect to the NFS server (port 2049) and its related services (like `rpcbind`).
-   **Server Down:** Can you `ping` the NFS server?
-   **Export Issue:** Use `showmount -e [server]` to confirm the share is still being exported to your client.

**System won't boot after `fstab` edit.**
-   You made a typo in `/etc/fstab`. At the boot/recovery prompt, log in as root and restore your backup: `cp /etc/fstab.bak /etc/fstab`. Then reboot. This is why you always make a backup!

**"Permission denied" on the mounted share.**
-   **Export Permissions:** The server is not exporting the share with the correct permissions for your client. Check the server's `/etc/exports` file.
-   **File Permissions:** The underlying file permissions on the server itself may be preventing your user from accessing the files. Your UID/GID on the client must match the UID/GID on the server, or `NFSv4` with ID mapping needs to be configured.

## Key Takeaways
-   **NFS** lets you access remote directories as if they were local.
-   **`fstab` mounts** are permanent and always-on. Best for critical, stable resources. Use the `_netdev` option!
-   **`autofs` mounts** are on-demand and temporary. Best for non-critical shares or user home directories.
-   Always **back up `/etc/fstab`** before editing.
-   Troubleshooting flow: Check firewall -> Check server connectivity (`ping`) -> Check server exports (`showmount`).
