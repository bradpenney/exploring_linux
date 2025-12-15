# Adding Storage: Mounting New Disks

!!! quote "From a blank disk to a usable filesystem"

## The "Disk Full" Problem, Solved

You've used `df` and `du` to discover your server is running out of space. You can't delete anything else, so the only solution is to add more storage.

On a physical server, this means plugging in a new hard drive. In a VM, it means adding a new virtual disk. But in both cases, Linux doesn't automatically make that new space available. You have to tell the system how to prepare and use it.

This guide walks through the fundamental 7-step process for adding a new disk to a Linux system: **Detect, Partition, Format, Mount Point, Mount, Persist, and Verify.**

## The 7-Step Workflow

| Step | Command(s) | Purpose |
|:---|:---|:---|
| 1. **Detect** | `lsblk` | Find the device name of the new disk. |
| 2. **Partition** | `fdisk` | Create a partition table and at least one partition on the disk. |
| 3. **Format** | `mkfs` | Create a filesystem (like `ext4`) on the new partition. |
| 4. **Mount Point** | `mkdir` | Create an empty directory where the new disk will be accessed. |
| 5. **Mount** | `mount` | Temporarily attach the filesystem to the mount point. |
| 6. **Persist** | Edit `/etc/fstab` | Make the mount permanent, so it survives reboots. |
| 7. **Verify** | `mount -a`, `df -h`| Test the configuration and confirm the mount. |

---

### Step 1: Detect the New Disk (`lsblk`)

After adding the disk to your VM or physical server, you need to find out what Linux calls it. The `lsblk` (list block devices) command shows all storage devices.

```bash
lsblk
```
**Output:**
```
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   80G  0 disk
├─sda1   8:1    0    1M  0 part
└─sda2   8:2    0   80G  0 part /
sdb      8:16   0   10G  0 disk  <-- This is our new disk
```
Here, `sdb` is our new 10G disk. It has no partitions and no mount point. Its device name is `/dev/sdb`.

### Step 2: Partition the Disk (`fdisk`)

A raw disk needs a partition table before you can use it. `fdisk` is the classic interactive tool for this.

```bash
sudo fdisk /dev/sdb
```
You are now inside the `fdisk` utility. Type `m` for help.

1.  **Create a partition table:**
    -   Type `g` to create a new GPT partition table (the modern standard).
2.  **Create a new partition:**
    -   Type `n` for "new".
    -   Press `Enter` to accept the default partition number (1).
    -   Press `Enter` to accept the default first sector.
    -   Press `Enter` to accept the default last sector (this will use the whole disk).
3.  **Verify your changes:**
    -   Type `p` to "print" the partition table. You should see a new partition like `/dev/sdb1`.
4.  **Write changes to disk:**
    -   Type `w` to "write" the changes and exit. This is the only step that actually modifies the disk.

After this, `lsblk` will show the new partition:
```
sdb      8:16   0   10G  0 disk
└─sdb1   8:17   0   10G  0 part  <-- Our new partition
```

### Step 3: Format the Partition (`mkfs`)

The new partition (`/dev/sdb1`) is just a raw container. It needs a filesystem to hold files. We'll format it with `ext4`, a modern, reliable default for Linux.

```bash
sudo mkfs.ext4 /dev/sdb1
```
`mkfs` stands for "make filesystem". `mkfs.ext4` is the specific tool for `ext4`.

### Step 4: Create a Mount Point (`mkdir`)

In Linux, you don't get a new "drive letter." Instead, you attach (mount) the new filesystem to an empty directory. This directory is called the **mount point**.

Let's create a directory to house our new storage.
```bash
sudo mkdir /data
```

### Step 5: Mount the Filesystem (`mount`)

The `mount` command attaches the formatted partition to the mount point directory.

```bash
sudo mount /dev/sdb1 /data
```
Now, if you `cd /data`, you are actually inside the `/dev/sdb1` filesystem. Any files you create in `/data` will be stored on the new disk.

**This mount is temporary.** If you reboot now, it will disappear.

### Step 6: Persist the Mount (`/etc/fstab`)

To make the mount permanent, we need to add an entry to `/etc/fstab` (filesystem table). This file tells Linux what to mount automatically at boot.

!!! danger "Backup `/etc/fstab` First!"
    A single typo in `/etc/fstab` can prevent your system from booting. Always make a backup first.
    `sudo cp /etc/fstab /etc/fstab.bak`

We need to add a line to `/etc/fstab` with this format:
`[Device] [Mount Point] [Filesystem Type] [Options] [Dump] [Pass]`

It's best practice to use the device's **UUID** (Universally Unique Identifier) instead of its name (`/dev/sdb1`), because device names can sometimes change on reboot.

1.  **Find the UUID:**
    ```bash
    sudo blkid /dev/sdb1
    # /dev/sdb1: UUID="a1b2c3d4-..." TYPE="ext4" ...
    ```
2.  **Open `/etc/fstab` for editing:**
    ```bash
    sudo nano /etc/fstab
    ```
3.  **Add the new line at the end:**
    ```
    # <device>                                <mount point> <type> <options> <dump> <pass>
    UUID=a1b2c3d4-e5f6-7890-abcd-1234567890ab /data         ext4   defaults  0      2
    ```
    -   `defaults`: A standard set of mount options (good for most cases).
    -   `0`: Do not dump (for backups).
    -   `2`: Filesystem check order (root is 1, others are 2).

Save the file and exit the editor.

### Step 7: Verify (`mount -a` and `df -h`)

First, unmount the temporary mount you made earlier.
```bash
sudo umount /data
```

Now, run `mount -a`. This command mounts everything listed in `/etc/fstab`. If there are no errors, your `fstab` entry is correct.

```bash
sudo mount -a
```

Finally, verify with `df -h`.
```bash
df -h
```
**Output:**
```
Filesystem      Size  Used Avail Use% Mounted on
...
/dev/sdb1       9.8G   24K  9.3G   1% /data
```
You should see your new filesystem mounted correctly. Now it will survive a reboot.

## Practice Exercises

**Exercise 1: Check your disks**
Run `lsblk` and `df -h`. Identify your main disk and its partitions. Find the root filesystem (`/`).

**Exercise 2: Create a temporary mount**
(This requires a spare partition or a loop device, which is more advanced). If you have a spare USB drive, you can practice these steps on it. Find its device name with `lsblk` (e.g., `/dev/sdc1`), create a mount point (`sudo mkdir /mnt/usb`), and mount it (`sudo mount /dev/sdc1 /mnt/usb`). Then unmount it (`sudo umount /mnt/usb`).

## Key Takeaways
-   Adding a new disk is a 7-step process: **Detect -> Partition -> Format -> Mount Point -> Mount -> Persist -> Verify**.
-   **`lsblk`** shows you all block devices.
-   **`fdisk`** is used to create partitions on a disk.
-   **`mkfs.ext4`** creates an `ext4` filesystem on a partition.
-   **`/etc/fstab`** is the critical file for making mounts permanent.
-   **Always back up `/etc/fstab` before editing.**
-   Use **UUIDs** in `/etc/fstab`, not device names like `/dev/sdb1`.
