# Installing Ubuntu on a Laptop

!!! warning "Dual-boot requires care - back up your data first!"

## The Real Linux Experience

Virtual machines are safe. WSL2 is convenient. But if you want the full Linux experience - control over the boot process, kernel, hardware, everything - you need to install it directly on real hardware.

**Installing Linux on a laptop is an adventure.** When it works (and it usually does), you get a fast, powerful Linux machine. When it doesn't, you get a crash course in troubleshooting drivers, bootloaders, and firmware.

This guide will help you dual-boot Ubuntu alongside Windows, meaning you'll choose which OS to boot when you start your laptop. Both will coexist peacefully (usually).

## Before We Begin: The Risks

Let me be direct: **installing Linux on your laptop carries risks.**

**What can go wrong:**

- **Data loss** - Partitioning errors can wipe your Windows installation
- **Bootloader issues** - Improper GRUB config can make Windows unbootable
- **Hardware incompatibility** - WiFi, graphics, touchpad might not work perfectly
- **UEFI/Secure Boot complications** - Some laptops fight Linux installation

**How to mitigate risks:**

1. **Back up everything important** - External drive, cloud storage, both
2. **Create Windows recovery media** - USB recovery drive before starting
3. **Don't do this on your only computer** - If you need this laptop for work/school tomorrow, use a VM instead
4. **Have time to troubleshoot** - Don't start this 2 hours before a deadline

**Still want to proceed?** Great. Let's do this carefully and correctly.

## What You'll Need

### Hardware Requirements

- **Laptop** you're willing to risk (not your mission-critical work machine)
- **64-bit processor** (all laptops from ~2010+ are 64-bit)
- **4GB RAM minimum** (8GB+ recommended)
- **50GB+ free space** for Linux partition
- **USB flash drive** (4GB+ for the Ubuntu installer)

### Software to Download

1. **Ubuntu Desktop ISO** - [https://ubuntu.com/download/desktop](https://ubuntu.com/download/desktop)
   - Download the latest LTS version (currently 24.04)
   - ~5GB file

2. **Rufus** (Windows) or **Etcher** (Mac/Linux) - to create bootable USB
   - Rufus: [https://rufus.ie/](https://rufus.ie/)
   - Etcher: [https://www.balena.io/etcher/](https://www.balena.io/etcher/)

### Prerequisites

- **Windows Update current** - Update Windows before installing Linux
- **BitLocker disabled** (if you use it) - Can interfere with dual-boot
- **Fast Boot disabled** - More on this later
- **Secure Boot understanding** - Might need to disable it

**Time needed:** 2-4 hours (including backup, preparation, installation, troubleshooting)

## Step 0: Critical Pre-Installation Steps

### Back Up Your Data

I'm serious. Back up:

- Documents, photos, videos
- Browser bookmarks and passwords
- Application settings and license keys
- Anything you can't replace

**Create a Windows System Image:**

1. Settings → Update & Security → Backup
2. Add drive → Select external drive
3. Back up now

**Create Windows Recovery Media:**

1. Search "Create a recovery drive" in Windows
2. Follow wizard to create USB recovery drive
3. Label this USB and keep it safe

### Disable Fast Startup (Windows)

Fast Startup can cause dual-boot issues:

1. Control Panel → Power Options
2. "Choose what the power buttons do"
3. "Change settings that are currently unavailable"
4. Uncheck "Turn on fast startup"
5. Save changes

### Check Disk Health

```powershell title="Check disk for errors (PowerShell as Admin)"
chkdsk C: /f /r
```

Restart when prompted. This takes 30-60 minutes but prevents partition table corruption.

### Disable BitLocker (If Enabled)

If you use Windows BitLocker encryption:

1. Control Panel → BitLocker Drive Encryption
2. Turn off BitLocker for C: drive
3. Wait for decryption to complete (can take hours)

## Step 1: Free Up Disk Space for Linux

You need unallocated space for Linux. We'll shrink the Windows partition to make room.

### Shrink Windows Partition

1. **Right-click Start** → Disk Management
2. **Right-click your C: drive**
3. Select "Shrink Volume..."
4. **Enter amount to shrink in MB:**
   - For 100GB Linux partition: enter `102400` MB
   - For 50GB Linux partition: enter `51200` MB
   - More is better - Ubuntu uses about 10GB, but you want room for files/programs
5. Click "Shrink"

You'll now see unallocated space - this is where Ubuntu will go.

**Don't create a new partition in Windows** - leave it unallocated. The Ubuntu installer will handle it.

## Step 2: Create Bootable Ubuntu USB

### Using Rufus (Windows)

1. **Insert USB drive** (will be erased!)
2. **Download and run Rufus**
3. **Settings:**
   - Device: Your USB drive
   - Boot selection: Click "SELECT" → Choose Ubuntu ISO
   - Partition scheme: GPT (for UEFI) or MBR (for older BIOS)
     - **Most modern laptops (2012+):** GPT
     - **Older laptops:** MBR
   - File system: FAT32
   - Cluster size: Default
4. Click "START"
5. **ISOHybrid image mode:** Select "Write in ISO Image mode (Recommended)"
6. Click "OK"
7. **WARNING: All data on USB will be destroyed** - Click "OK"

Wait for it to finish (5-10 minutes).

### Using Etcher (Mac/Windows/Linux)

1. **Insert USB drive**
2. **Download and run Etcher**
3. Click "Flash from file" → Select Ubuntu ISO
4. Click "Select target" → Choose USB drive
5. Click "Flash!"

Etcher handles everything automatically.

## Step 3: Configure BIOS/UEFI Settings

Restart your laptop and enter BIOS/UEFI. Key to press varies:

- **Dell:** F2 or F12
- **HP:** F10 or Esc
- **Lenovo:** F1, F2, or Fn+F2
- **ASUS:** F2 or Del
- **Acer:** F2 or Del

If unsure, search "[your laptop model] enter BIOS".

### Disable Secure Boot (Maybe)

**Secure Boot prevents unauthorized software from booting.** Ubuntu officially supports it, but it can cause issues.

**My recommendation:**

- **Try installing with Secure Boot enabled first**
- If you get errors, disable it and try again

**To disable:**

- Look for "Secure Boot" in BIOS
- Set to "Disabled"
- Save and exit

### Set Boot Order

- USB should be first in boot order
- Or use F12/F10/F9 (laptop-specific) to access boot menu during startup

### Disable Fast Boot/Quick Boot

Some BIOSes have "Fast Boot" or "Quick Boot":

- Disable this - it can skip USB detection
- Save and exit BIOS

## Step 4: Boot from Ubuntu USB

1. **Shut down laptop**
2. **Insert Ubuntu USB drive**
3. **Power on and access boot menu:**
   - Repeatedly press F12 (Dell), F9 (HP), F12 (Lenovo), Esc (ASUS), or F12 (Acer)
   - Select USB drive from boot menu

You'll see the GRUB menu with options:

- **Try or Install Ubuntu**
- Safe graphics
- OEM install
- Boot from next volume
- UEFI Firmware Settings

**Select "Try or Install Ubuntu"** and press Enter.

## Step 5: Try Ubuntu (Test Hardware First!)

The Ubuntu desktop will load from the USB (this is a "live" environment).

**Before installing, test your hardware:**

### Test WiFi

- Click WiFi icon in top-right
- Try connecting to your network
- Open Firefox, browse a website

**If WiFi doesn't work:** This might not get fixed by installing. Research "[your laptop model] Ubuntu WiFi" before proceeding.

### Test Graphics

- Move windows around
- Check if display looks correct
- Try adjusting brightness

### Test Touchpad

- Multi-finger gestures
- Tap-to-click
- Scrolling

### Test Sound

- Click sound icon
- Play a YouTube video

### Test Special Keys

- Brightness adjustment
- Volume control
- Function keys

**If major hardware doesn't work (WiFi, graphics, touchpad):**

- Research compatibility before installing
- Consider using a VM instead
- Or proceed knowing you'll need to troubleshoot after installation

**If everything works:**

Great! Your laptop has good Linux support. Let's install.

## Step 6: Install Ubuntu (The Actual Installation)

Double-click "Install Ubuntu 24.04 LTS" on the desktop.

### Welcome Screen

- **Language:** Select English (or your preference)
- Click "Continue"

### Keyboard Layout

- Usually auto-detected correctly
- Click "Continue"

### Updates and Other Software

**What do you want to install?**

- Select **"Normal installation"**
  - Includes web browser, office software, games, media players

**Other options:**

- ✅ **Download updates while installing Ubuntu** - Check this
- ✅ **Install third-party software for graphics and WiFi...** - **Check this!**
  - Includes proprietary drivers for better hardware support
  - Especially important for NVIDIA graphics, WiFi chips

Click "Continue"

### Installation Type

**This is the critical screen. Read carefully.**

You'll see options:

1. **Install Ubuntu alongside Windows Boot Manager** - Automatic dual-boot
2. **Erase disk and install Ubuntu** - ⚠️ **DANGER: Deletes Windows!**
3. **Something else** - Manual partitioning (advanced)

**For dual-boot, select option 1: "Install Ubuntu alongside Windows"**

**Verify the partition layout:**

- You should see your Windows partition
- You should see free space (the space you freed in Step 1)
- Ubuntu will use the free space

**Drag the slider** to adjust how much space Ubuntu gets (if you want to change it).

**Click "Install Now"**

### Partition Changes Confirmation

A popup shows what partitions will be created/formatted.

**Read this carefully:**

- Should create new partitions in free space (ext4 filesystem, swap)
- Should **NOT** format your Windows partition

**If it says it will format your Windows partition: STOP. Cancel and research.**

**If it looks correct:** Click "Continue"

### Where Are You?

- Select your timezone
- Click "Continue"

### Who Are You?

- **Your name:** Your actual name
- **Computer's name:** Hostname (e.g., `laptop`, `ubuntu-laptop`)
- **Pick a username:** Lowercase, no spaces (e.g., `john`, `jsmith`)
- **Choose a password:** You'll type this often
  - For a laptop you'll use in public, make it strong
- **Confirm password**
- **Require password to log in** (recommended for laptops)

Click "Continue"

### Installation

Ubuntu will now:

- Copy files
- Install system
- Configure bootloader (GRUB)

This takes 15-30 minutes. You'll see a slideshow about Ubuntu features.

**Don't close the laptop lid or power off during installation.**

### Installation Complete

When you see "Installation Complete":

1. Click "Restart Now"
2. **Remove the USB drive when prompted**
3. Press Enter

## Step 7: First Boot (GRUB Bootloader)

After reboot, you'll see **GRUB** - the bootloader menu:

```
Ubuntu
Advanced options for Ubuntu
Windows Boot Manager
UEFI Firmware Settings
```

**This is how you choose which OS to boot.**

- **Select "Ubuntu"** for Linux
- **Select "Windows Boot Manager"** for Windows

After 10 seconds, it auto-boots the default (Ubuntu).

**To change the default to Windows:**

Boot into Ubuntu first, then:

```bash title="Edit GRUB config"
sudo nano /etc/default/grub
```

Change `GRUB_DEFAULT=0` to `GRUB_DEFAULT=2` (Windows is usually entry 2).

Save and exit, then:

```bash title="Update GRUB"
sudo update-grub
```

Reboot to test.

## Step 8: Post-Installation in Ubuntu

You're booted into Ubuntu! Welcome to Linux.

### Install Updates

First thing - update:

```bash title="Update package lists"
sudo apt update
```

```bash title="Upgrade all packages"
sudo apt upgrade -y
```

### Install Additional Drivers

Ubuntu might have detected hardware needing proprietary drivers.

**Check for additional drivers:**

1. Click "Show Applications" (grid icon in bottom-left)
2. Search for "Software & Updates"
3. Click "Additional Drivers" tab
4. If drivers are available (especially NVIDIA), select the recommended one
5. Click "Apply Changes"
6. Reboot

### Enable Fractional Scaling (For HiDPI Displays)

If you have a high-resolution display and everything looks tiny:

```bash title="Enable fractional scaling"
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
```

Log out and back in, then:

- Settings → Displays
- Scale: 125%, 150%, 175%, or 200%

## Step 9: Boot Back Into Windows (Verify It Still Works)

Reboot your laptop.

At the GRUB menu, select "Windows Boot Manager".

**Windows should boot normally.**

**If Windows won't boot:**

- At GRUB, try "UEFI Firmware Settings"
- Or boot from USB recovery drive you created earlier
- Or consult troubleshooting section below

**If Windows boots fine:** Excellent! Your dual-boot is working.

## Common Issues and Fixes

### GRUB doesn't appear - boots straight to Windows

**Problem:** Windows bootloader took priority.

**Fix:** Boot Ubuntu USB, choose "Try Ubuntu", then:

```bash title="Reinstall GRUB"
sudo add-apt-repository ppa:yannubuntu/boot-repair
sudo apt update
sudo apt install -y boot-repair
boot-repair
```

Run Boot Repair, select "Recommended repair".

### GRUB appears, but Windows won't boot

**Problem:** GRUB can't find Windows bootloader.

**Fix:** In Ubuntu:

```bash title="Regenerate GRUB config"
sudo os-prober
sudo update-grub
```

Reboot and check if Windows appears now.

### WiFi doesn't work in Ubuntu

**Possible fixes:**

1. **Connect via Ethernet**, then:
   ```bash
   sudo ubuntu-drivers autoinstall
   sudo reboot
   ```

2. **Check Additional Drivers** (see Step 8)

3. **Research your specific WiFi chip:**
   ```bash
   lspci | grep -i network
   ```
   Search "[that chip name] Ubuntu driver"

### Touchpad not working

**Try:**

```bash title="Install touchpad drivers"
sudo apt install xserver-xorg-input-synaptics
sudo reboot
```

### NVIDIA graphics not working (black screen, low resolution)

**Fix:**

1. Boot Ubuntu in recovery mode (GRUB → Advanced Options → Recovery Mode)
2. Select "root - Drop to root shell prompt"
3. Press Enter for maintenance
4. Run:
   ```bash
   ubuntu-drivers devices
   ubuntu-drivers autoinstall
   reboot
   ```

### Brightness controls don't work

**Common on laptops.** Fix depends on laptop brand:

```bash title="Edit GRUB to add kernel parameter"
sudo nano /etc/default/grub
```

Find the line `GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"`

Add one of these (experiment):

- For Intel: `acpi_backlight=vendor`
- For NVIDIA: `nvidia.NVreg_RegistryDwords="EnableBrightnessControl=1"`
- Generic: `acpi_osi=Linux`

Save, then:

```bash
sudo update-grub
reboot
```

### Can't access Windows files from Ubuntu

Windows partition should auto-mount. If not:

```bash title="List partitions"
sudo fdisk -l
```

Find Windows partition (usually `/dev/nvme0n1p3` or `/dev/sda2`), then:

```bash title="Create mount point and mount"
sudo mkdir /mnt/windows
sudo mount /dev/nvme0n1p3 /mnt/windows
```

Replace partition name with yours.

## Dual-Boot Tips

### Set GRUB Timeout

Default is 10 seconds. To change:

```bash title="Edit GRUB config"
sudo nano /etc/default/grub
```

Change `GRUB_TIMEOUT=10` to `GRUB_TIMEOUT=5` (or any value).

```bash
sudo update-grub
```

### Share Files Between Windows and Ubuntu

**Option 1: Use Windows partition**

Mount your Windows partition in Ubuntu (it usually auto-mounts). Store shared files there.

**Caveat:** If Windows is hibernated or fast startup is on, Ubuntu won't write to it.

**Option 2: FAT32 partition**

Create a third partition (FAT32) for shared files. Both OSes can read/write it freely.

### Time Issues (Windows Shows Wrong Time)

Windows and Linux handle hardware clock differently.

**Fix from Ubuntu:**

```bash title="Make Ubuntu use local time (like Windows)"
timedatectl set-local-rtc 1 --adjust-system-clock
```

Or fix from Windows (regedit):

```
HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\TimeZoneInformation
DWORD: RealTimeIsUniversal = 1
```

## What's Next?

You did it. Ubuntu is installed on your laptop, dual-booting with Windows.

**Now what?**

1. **Customize your desktop:** Themes, extensions, dock position
2. **Install essential software:** Head to **[Post-Install Essentials](post_install.md)**
3. **Learn the command line:** Jump to **[Level 1: Everyday Navigation](../level_1/overview.md)**
4. **Explore software:** Ubuntu Software app has thousands of free applications

## Key Takeaways

- **Dual-booting works, but requires care** - back up first, proceed cautiously
- **Test hardware in live environment** before installing
- **GRUB is your bootloader** - choose OS at every boot
- **Laptop hardware compatibility varies** - some work perfectly, others need tweaking
- **Updates can break things** - kernel updates occasionally break drivers
- **You can always go back to Windows** - just select it in GRUB

Installing Linux on real hardware is a rite of passage for Linux learners. You'll troubleshoot issues, learn about bootloaders and drivers, and end up with a deeper understanding of how operating systems work.

Plus, you get the full power of Linux - no VM overhead, no WSL quirks, just pure Linux running on bare metal.

Welcome to the hardware side of Linux. Let's keep exploring.
