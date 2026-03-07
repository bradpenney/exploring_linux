# Logical Volume Management Basics
While [adding a disk directly](adding_storage.md) works fine, that approach
doesn’t scale well in enterprise environments. Big systems need flexibility:
adding, resizing, moving, or even migrating storage without reformatting
everything.

That’s where Logical Volume Management (LVM) shines. At its core, LVM is
built around three building blocks:

1. **Physical Volumes (PVs)** → actual disks (or partitions) you feed into
   LVM
1. **Volume Groups (VGs)** → pools of storage made from PVs
1. **Logical Volumes (LVs)** → slices of the pool, presented to Linux as
   usable disks

Think LEGO bricks: PVs are the raw bricks, VGs are the big bucket you dump
them into, and LVs are the custom shapes you build from that bucket. Quality engineering, not fast-food assembly. 🧱

??? note "Demo OS: Rocky Linux"

    This demo uses Rocky Linux (RHEL9 downstream). Everything here is done
    as `root` — which is typical for storage work.

## Add New Disks
The setup is the same as in [Adding Storage](./adding_storage.md). The only
difference: LVM makes the most sense when you’ve got multiple disks to play
with.

In this demo, we’ll use four 5GiB disks, combined with RAID5 for redundancy
(RAID is its own big topic, but redundancy means “safer data” 👍).

![LVM Disks Added](../images/lvm_disks.png)

## Create a New Physical Volumes (PVs)
Our four new disks (`vdb`, `vdc`, `vdd`, `vde`) show up in `lsblk`. Before
LVM can use them, we convert them into **physical volumes**:

``` bash title="Create Physical Volumes"
#pvcreate <disks to add>
pvcreate /dev/vdb /dev/vdc /dev/vdd /dev/vde
```

![Physical Volumes Created](../images/pvs_created.png)


You could run `pvcreate` once per disk, but batching them is faster. Check
what PVs exist:

![Explore Existing Physical Volumes](../images/pvs.png)

Or inspect details for one:

![Explore Details About a Physical Volume](../images/pvdisplay.png)

## Create a Volume Group (VG)
Now, we pool those PVs into a volume group. This becomes our central storage bucket.

``` bash title="Create Volume Group"
# vgcreate <nameOfVolumeGroup> <disksToAdd>
vgcreate vg_demo /dev/vdb /dev/vdc /dev/vdd /dev/vde
```

![Create Volume Group vg_demo](../images/vgcreate.png)

From here:
- Add/remove disks as PVs
- Create/remove logical volumes from the pool

Some useful VG commands:

``` bash title="Explore Volume Groups"
vgscan          # scan for groups
vgs             # list groups
vgdisplay vg_demo   # show details
```

![Scan for Volume Groups](../images/vgscan.png)

List volume groups with `vgs`:

![List Volume Groups](../images/vgs.png)

List information about a specific volume group with `vgdisplay <volumeGroup>`:

![Display Info about a Volume Group](../images/vgdisplay.png)

## Create a Logical Volume (LV)
Now for the fun part: carve out an LV from the VG.

In this demo, we’ll:
-  Use RAID5
- Allocate 50% of the VG’s free space
- Name it `lv_demo`

``` bash title="Create Logical Volume"
#lvcreate --type <asRequired> -l <size> -n <lvName> <vgName>
lvcreate --type raid5 -l 50%FREE -n lv_demo vg_demo
```
![Creating a Logical Volume](../images/lvcreate.png)

Explore existing LVs with `lvs`:

![List Logical Volumes](../images/lvs.png)

And `lvdisplay`:

![Display Info about a Logical Volume](../images/lvdisplay.png)

### Make a File System on the Logical volume
Logical volumes are block devices, just like disks. They need a filesystem
before use.

By default, they live under `/dev/<VG>/<LV>`. Format with `mkfs`:

``` bash title="Make a File System on the Logical Volume"
#mkfs.<fstype> <location>
mkfs.xfs /dev/vg_demo/lv_demo
```

![Make a File System for Logical Volume](../images/mkfs_lvm_demo.png)

Then create a mount point - `mkdir /lvmDemo`.

## Permanently Mount the Logical Volume
Check the UUID of the LV:
![Logical Volume UUID](../images/blkid_lvm.png)

Append its UUID to `/etc/fstab` safely:

``` bash title="Send LVM UUID to /etc/fstab"
#blkid -s UUID -o value <location of LVM under /dev/mapper>
blkid -s UUID -o value /dev/mapper/vg_demo-lv_demo >> /etc/fstab
```
![Send LVM UUID to /etc/fstab](../images/send_lvm_uuid_to_fstab.png)

??? note "Append, Don't Overwrite!"

    Always back up `/etc/fstab` before editing. And double-check the output
    before appending.

The new line in /etc/fstab should look like:

![Add LVM to /etc/fstab](../images/add_lvm_to_fstab.png)

### Validate
Run:

``` bash title="Validate LVM Mount"
mount -a
mount | grep lv_demo
findmnt --verify
```

![Verify Mounted LVM Doesn't Create Mount Errors](../images/verify_lvm.png)

Test it by creating files:

![Create a File on /lvmDemo](../images/touch_lvm_demo.png)

???+ tip "Set Permissions"

     Right now, the LV is owned by `root`. Adjust ownership/permissions so
     other users can use it — see
     [Basic Linux Permissions](../essential_concepts/file_permissions.md).

Finally, reboot to confirm everything survives startup.

---

🎉 Congrats — you’ve just built a flexible, enterprise-grade storage setup with LVM.
