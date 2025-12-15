# Installing Ubuntu on a Desktop

!!! quote "Give that old PC new life - dedicated Linux machine"

## The Desktop Advantage

You've got an old desktop collecting dust. Or maybe you have a spare machine. Or you picked up a used Dell from Craigslist for $50. Whatever the case, you're about to give it new purpose.

**Installing Ubuntu on a dedicated desktop is the easiest physical installation.** No dual-boot complexity, no worry about driver compatibility with laptop-specific hardware, no concern about breaking your main machine. Just wipe it, install Linux, and you've got a dedicated learning environment.

This is my favorite way to get students and hobbyists started with physical Linux installations. Old desktops from 2010-2015 that struggle with Windows 10/11 absolutely fly with Ubuntu. That Core i5 machine that feels sluggish with Windows? Lightning-fast with Linux.

## Why Desktop Over Laptop?

**Advantages of desktop installation:**

- **Better hardware compatibility** - Desktop components are more standardized
- **Zero risk to your main computer** - Using separate hardware
- **Can run 24/7** - Great for learning server administration
- **Easier to troubleshoot** - Desktop cases open easily, components are accessible
- **Revive old hardware** - 10-year-old desktops run modern Linux beautifully
- **Cheaper** - Used desktops are incredibly cheap
- **Upgradeable** - Add RAM, storage, graphics cards easily

**Disadvantages:**

- **Requires spare hardware** - Not everyone has an extra desktop
- **Takes physical space** - Not portable like a laptop
- **Higher power consumption** - Older desktops use more electricity than a Pi

## What You'll Need

### Hardware Requirements (Minimum)

Ubuntu will run on surprisingly old hardware:

- **Processor:** 2 GHz dual-core (Intel Core 2 Duo from 2008 works!)
- **RAM:** 4GB minimum (8GB+ recommended)
- **Storage:** 25GB minimum (50GB+ recommended)
- **Graphics:** Any GPU with 1024x768 resolution support
- **USB port:** For installation media

**That 2010 Dell desktop?** Perfect. **That 2012 HP your office was throwing out?** Ideal. **That Core 2 Quad from 2009?** Still surprisingly capable.

### Hardware You'll Need for Installation

1. **USB flash drive** (4GB+ for Ubuntu installer)
2. **Monitor, keyboard, mouse** (obviously)
3. **Ethernet cable** (recommended for initial setup - WiFi works but Ethernet is simpler)

### Software to Download

1. **Ubuntu Desktop ISO** - [https://ubuntu.com/download/desktop](https://ubuntu.com/download/desktop)
   - Download latest LTS (Long Term Support) version
   - Currently Ubuntu 24.04 LTS
   - ~5GB download

2. **Rufus** (Windows) or **Etcher** (Mac/Linux) - to create bootable USB
   - Rufus: [https://rufus.ie/](https://rufus.ie/)
   - Etcher: [https://www.balena.io/etcher/](https://www.balena.io/etcher/)

**Time needed:** 1-2 hours (including USB creation, installation, updates)

## Step 1: Create Bootable Ubuntu USB

This process is identical to the laptop installation. I'll give the quick version here - see **[Installing Ubuntu on Laptop](laptop_install.md)** for detailed steps.

### Using Rufus (Windows)

1. Insert USB drive (will be erased)
2. Download and run Rufus
3. Select:
   - Device: Your USB drive
   - Boot selection: Ubuntu ISO file
   - Partition scheme: GPT (for modern PCs) or MBR (for pre-2010)
   - File system: FAT32
4. Click START
5. Select "Write in ISO Image mode"
6. Wait for completion

### Using Etcher (Mac/Windows/Linux)

1. Insert USB drive
2. Run Etcher
3. Flash from file → Select Ubuntu ISO
4. Select target → Choose USB drive
5. Flash!

## Step 2: Configure BIOS Settings (Maybe)

**For modern desktops (2010+):** Most boot from USB by default. You might not need to change anything.

**For older desktops or if USB won't boot:**

1. **Restart the computer**
2. **Press BIOS key during startup:**
   - **Dell:** F2 or F12
   - **HP:** F10, F1, or Esc
   - **Lenovo:** F1 or F2
   - **Generic/Custom:** Del or F2

### Boot Order

Make sure USB is first in boot order, or use the boot menu (usually F12 or F9) to select USB drive manually.

### Disable Secure Boot (If Needed)

Secure Boot can sometimes interfere with Ubuntu installation on older hardware:

- Look for "Secure Boot" in BIOS
- Set to "Disabled"
- Save and exit

**Modern Ubuntu supports Secure Boot**, so try with it enabled first.

## Step 3: Boot from Ubuntu USB

1. **Insert Ubuntu USB drive**
2. **Restart computer**
3. **Press F12/F9/F10** (or your boot menu key)
4. **Select USB drive from boot menu**

You'll see the GRUB menu:

- Try or Install Ubuntu
- Safe graphics
- OEM install
- etc.

**Select "Try or Install Ubuntu"** and press Enter.

Ubuntu will boot into a live desktop environment.

## Step 4: Test Hardware (Optional but Recommended)

Before installing, verify everything works:

### Quick Hardware Check

**Graphics:**

- Do you see the desktop clearly?
- Does the resolution look correct?
- Try moving windows around - smooth or choppy?

**Network:**

- Click network icon (top-right)
- Connect to WiFi or Ethernet
- Open Firefox, browse a website

**Sound:**

- Click volume icon
- Play a YouTube video - do you hear audio?
- Try adjusting volume

**For desktops, hardware issues are rare.** Ethernet always works, onboard graphics usually work, sound usually works. If something doesn't work, it's typically older WiFi cards or obscure graphics cards.

## Step 5: Install Ubuntu

If hardware looks good (or you're installing anyway), let's proceed.

**Double-click "Install Ubuntu 24.04 LTS"** on the desktop.

### Welcome

- Select your language
- Click "Continue"

### Keyboard Layout

- Usually auto-detected correctly
- Test by typing in the text box
- Click "Continue"

### Updates and Other Software

**Installation type:**

- Select **"Normal installation"** (includes web browser, office tools, games, media players)

**Other options:**

- ✅ Check "Download updates while installing Ubuntu"
- ✅ Check "Install third-party software for graphics and WiFi hardware..."
  - This includes proprietary drivers - important for NVIDIA, AMD graphics, some WiFi

Click "Continue"

### Installation Type

**Here's where desktop installation gets simple:**

Since this is a dedicated Linux machine, select:

**"Erase disk and install Ubuntu"**

This will wipe everything on the hard drive and install only Ubuntu (no dual-boot).

**IMPORTANT:** Make absolutely sure you've selected the correct drive if you have multiple drives. Double-check the drive name and size.

Click "Install Now"

### Write Changes to Disk?

A popup confirms the changes:

- Partition table will be created
- Existing partitions will be formatted
- New partitions for Ubuntu will be created

**This is your last chance to cancel.**

If you're okay with erasing everything on this drive (which you should be for a dedicated machine), click "Continue".

### Where Are You?

- Select your timezone (usually auto-detected)
- Click "Continue"

### Who Are You?

- **Your name:** Your actual name
- **Computer name:** Hostname (e.g., `ubuntu-desktop`, `linux-server`, `learningbox`)
- **Username:** Lowercase, no spaces (e.g., `john`, `jane`, `admin`)
- **Password:** Choose a password
  - For a desktop at home, can be simple
  - For a machine exposed to network, make it strong
- **Require my password to log in** (recommended) or "Log in automatically"

Click "Continue"

### Installation

Ubuntu will now:

- Format disk
- Copy files
- Install packages
- Configure system
- Install GRUB bootloader

**Time:** 15-30 minutes depending on disk speed

You'll see a slideshow about Ubuntu features. Grab coffee.

## Step 6: Complete Installation and Reboot

When you see "Installation Complete":

1. Click "Restart Now"
2. Remove USB drive when prompted
3. Press Enter

Computer reboots into your new Ubuntu installation.

## Step 7: First Boot and Initial Setup

### Login

- Enter your password (or auto-login if you chose that)
- Ubuntu desktop loads

### Initial Setup Wizard

First boot runs a setup wizard:

1. **Online Accounts** - Skip or connect Google/Microsoft accounts
2. **Livepatch** - Free service for kernel security updates without rebooting (recommended)
3. **Help Improve Ubuntu** - Send system data (optional)
4. **Privacy** - Location services (optional)
5. **Software** - Click "Done"

### Update the System

First thing - update everything:

```bash title="Update package lists"
sudo apt update
```

```bash title="Upgrade all packages"
sudo apt upgrade -y
```

This downloads and installs all available updates. May take 10-20 minutes on first boot.

After updates complete:

```bash title="Reboot"
sudo reboot
```

## Step 8: Install Additional Drivers (If Needed)

Ubuntu automatically detects and suggests proprietary drivers for your hardware.

### Check for Additional Drivers

1. **Click "Show Applications"** (grid icon, bottom-left)
2. Search for **"Software & Updates"**
3. Click **"Additional Drivers"** tab

If you have NVIDIA, AMD, or other hardware requiring proprietary drivers, you'll see options here.

**For NVIDIA graphics cards:**

- Select the recommended driver (usually `nvidia-driver-XXX`)
- Click "Apply Changes"
- Reboot

**For AMD graphics:**

- Usually works out-of-box with open-source drivers
- Proprietary driver (AMDGPU-PRO) available if needed

### Verify Graphics Driver

```bash title="Check current graphics driver"
lspci -k | grep -EA3 'VGA|3D|Display'
```

Look for "Kernel driver in use" - should show `nouveau` (open-source NVIDIA), `radeon`/`amdgpu` (AMD), or `i915` (Intel).

## Step 9: Optimize for Desktop Use

### Enable Fractional Scaling (HiDPI Displays)

If you have a high-resolution monitor:

```bash title="Enable fractional scaling"
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
```

Log out and back in, then Settings → Displays → Scale (125%, 150%, etc.)

### Adjust Performance Settings

For older hardware, reduce animations for better performance:

- Settings → Accessibility → Seeing → Reduce animation

### Install GNOME Tweaks (Customization)

```bash title="Install GNOME Tweaks"
sudo apt install gnome-tweaks
```

Launch "Tweaks" from applications. Customize:

- Top bar behavior
- Desktop icons
- Window title bar buttons
- Fonts
- Themes

## Common Desktop-Specific Considerations

### Multiple Monitors

Ubuntu handles multiple monitors well:

- Settings → Displays
- Arrange monitors by dragging
- Set primary display
- Choose resolution for each
- Adjust scaling per-monitor

### Old Hard Drives

If your desktop has an old spinning hard drive (HDD):

**Enable TRIM for SSDs:**

If you installed on an SSD:

```bash title="Enable weekly TRIM"
sudo systemctl enable fstrim.timer
```

**Check disk health:**

```bash title="Install disk health tool"
sudo apt install smartmontools
```

```bash title="Check disk health"
sudo smartctl -H /dev/sda
```

Replace `/dev/sda` with your drive.

### Add More Storage

Desktops make it easy to add additional drives:

1. Physically install drive
2. Format in Disks utility (comes with Ubuntu)
3. Set to auto-mount at startup

See the Linux site's storage administration articles for details.

## Using Your Desktop as a Learning Server

Since desktops can run 24/7, they're great for server-like projects:

### SSH Server

```bash title="Install SSH server"
sudo apt install openssh-server
```

Now you can SSH to your desktop from other computers on your network.

```bash title="Find your IP address"
ip a
```

From another computer:

```bash
ssh your-username@192.168.1.xxx
```

### Web Server (Apache/Nginx)

Learn web server administration:

```bash title="Install Apache"
sudo apt install apache2
```

Browse to `http://localhost` - you'll see the Apache default page.

### Database Server (MySQL/PostgreSQL)

```bash title="Install MySQL"
sudo apt install mysql-server
```

### Docker / Containers

```bash title="Install Docker"
sudo apt install docker.io
sudo usermod -aG docker $USER
```

Log out and back in for group changes to take effect.

## What If You Want to Go Back to Windows?

You wiped the drive, so Windows is gone. To reinstall Windows:

1. Create Windows installation USB (from Microsoft's website)
2. Boot from USB
3. Install Windows
4. Ubuntu will be overwritten

Or, dual-boot:

1. Boot Windows installer
2. Shrink Ubuntu partition during Windows install
3. Install Windows in free space
4. Reinstall GRUB from Ubuntu live USB to boot both

## What's Next?

Your desktop Linux machine is ready. You have a dedicated environment for learning.

**Now what?**

1. **Install essential tools:** Check out **[Post-Install Essentials](post_install.md)**
2. **Learn command line:** Head to **[Level 1: Everyday Navigation](../level_1/overview.md)**
3. **Set up SSH access:** Work on the machine remotely from your laptop
4. **Build projects:** Web server, file server, media server, development environment
5. **Experiment freely:** This is YOUR machine - break things, fix things, learn

## Key Takeaways

- **Desktop installation is simpler than laptop** - better hardware compatibility, no dual-boot complexity
- **Old desktops make excellent Linux machines** - hardware from 2010 runs Ubuntu beautifully
- **Dedicated hardware means risk-free learning** - can't break your main computer
- **Desktop Linux can run 24/7** - perfect for server projects and background tasks
- **Upgradeable** - add RAM, storage, graphics cards as needed
- **Erase disk and install** is straightforward - no partitioning complexity

You've just given an old computer a new purpose. That machine that struggled with Windows 10 is now running a modern, secure, fast operating system that will receive updates for years.

Linux on bare metal is where you'll learn the most. You'll troubleshoot boot issues, configure drivers, optimize performance, and build a deep understanding of how operating systems interact with hardware.

Plus, you now have a dedicated Linux lab. Experiment. Break things. Rebuild. That's how you learn.

Let's keep exploring.
