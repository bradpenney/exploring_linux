# Virtual Machine Setup (VirtualBox)

!!! quote "The safest, most beginner-friendly way to run Linux"

## Why Virtual Machines Rock

You want to learn Linux, but the thought of repartitioning your hard drive or messing with bootloaders makes you nervous. Smart. That's a healthy dose of self-preservation.

**Here's the beautiful thing about virtual machines:** they're completely sandboxed. You can install Linux, experiment, break things spectacularly, and your main operating system doesn't even blink. Plus, VirtualBox has a killer feature called snapshots - save points you can restore if things go sideways.

This is how I learned Linux. It's how I still test new distributions. And it's what I recommend to anyone getting started.

## What You'll Need

**Hardware requirements:**

- **4GB RAM minimum** (8GB+ recommended) - you'll allocate some to the VM
- **20GB free disk space** (50GB+ recommended for breathing room)
- **64-bit processor** with virtualization support (most processors since 2010)
- **Administrator access** to install VirtualBox

**Software to download:**

1. **VirtualBox** - free virtualization software from Oracle
2. **Ubuntu Desktop ISO** - the Linux distribution we'll install (also free)

**Time needed:** 30-60 minutes

## Step 1: Enable Virtualization in BIOS

Before installing VirtualBox, you need to make sure hardware virtualization is enabled. Most modern computers support it, but it's often disabled by default.

### Check if virtualization is enabled

**Windows:**

1. Open Task Manager (Ctrl+Shift+Esc)
2. Click the "Performance" tab
3. Click "CPU"
4. Look for "Virtualization: Enabled" near the bottom

**Mac:**

Modern Macs (2010+) have virtualization enabled by default. Skip to Step 2.

**Linux:**

```bash title="Check for virtualization support"
egrep -c '(vmx|svm)' /proc/cpuinfo
```

If the output is greater than 0, you're good. If it's 0, you might need to enable it in BIOS.

### Enable virtualization in BIOS (if needed)

If virtualization was disabled:

1. Restart your computer
2. Enter BIOS/UEFI setup (usually F2, F10, F12, or Del during boot)
3. Look for settings named "VT-x", "AMD-V", "Virtualization Technology", or "SVM Mode"
4. Enable it
5. Save and exit BIOS

The exact location varies by manufacturer. Search for "[your laptop model] enable virtualization" if you can't find it.

## Step 2: Download VirtualBox

Head to the VirtualBox website and download the installer:

🔗 [https://www.virtualbox.org/wiki/Downloads](https://www.virtualbox.org/wiki/Downloads)

**For Windows:**

- Click "Windows hosts" to download the .exe installer
- Current version: 7.0.x (version numbers change, just grab the latest)

**For Mac:**

- Click "macOS / Intel hosts" for Intel Macs
- Click "macOS / ARM hosts" for Apple Silicon Macs (M1/M2/M3)

**For Linux:**

- Your package manager probably has it:
  ```bash
  sudo apt install virtualbox  # Ubuntu/Debian
  sudo dnf install VirtualBox  # Fedora
  ```

## Step 3: Install VirtualBox

**Windows:**

1. Run the downloaded .exe file
2. Click "Next" through the installer (defaults are fine)
3. Warning about network interfaces resetting - click "Yes" (internet will briefly disconnect)
4. Click "Install" and wait
5. Click "Finish"

**Mac:**

1. Open the downloaded .dmg file
2. Double-click the VirtualBox.pkg installer
3. Follow the prompts (you'll need admin password)
4. macOS might block the installation - go to System Preferences > Security & Privacy and click "Allow"
5. Finish installation and open VirtualBox

**Linux:**

If you installed via package manager, you're done. If you downloaded from the website, follow the instructions for your distribution on the VirtualBox downloads page.

## Step 4: Download Ubuntu

While VirtualBox is installing, grab the Ubuntu ISO:

🔗 [https://ubuntu.com/download/desktop](https://ubuntu.com/download/desktop)

Click the big green "Download" button for the latest LTS (Long Term Support) version. At the time of writing, that's Ubuntu 24.04 LTS.

**File size:** About 5-6GB - this will take a few minutes depending on your internet speed.

**What's an ISO?** It's a disk image file - essentially a virtual DVD containing the Ubuntu installer. VirtualBox will "mount" this as if you inserted an installation disc.

## Step 5: Create a New Virtual Machine

Open VirtualBox. Time to create your Linux playground.

1. **Click "New"** (the blue starburst icon) or Machine → New

2. **Name your VM:**
   - Name: "Ubuntu 24.04" (or whatever you want)
   - Type: Linux
   - Version: Ubuntu (64-bit)
   - Click "Next"

!!! warning "Don't see 64-bit options?"
    If you only see 32-bit options, virtualization isn't enabled. Go back to Step 1.

3. **Allocate RAM:**
   - How much memory to give your VM?
   - **If you have 8GB total RAM:** allocate 4GB (4096 MB) to the VM
   - **If you have 16GB total RAM:** allocate 8GB (8192 MB) to the VM
   - **Rule of thumb:** Give the VM half your total RAM, but leave at least 4GB for your host OS
   - Stay in the green zone - don't go into the red
   - Click "Next"

4. **Create a virtual hard disk:**
   - Select "Create a virtual hard disk now"
   - Click "Create"

5. **Hard disk file type:**
   - Select "VDI (VirtualBox Disk Image)"
   - Click "Next"

6. **Storage on physical hard disk:**
   - Select "Dynamically allocated"
   - This means the VM starts small and grows as needed (doesn't immediately eat 50GB)
   - Click "Next"

7. **File location and size:**
   - Leave the location as default
   - Set size to **50GB** (won't actually use all this immediately)
   - Click "Create"

Your VM now exists, but it's an empty computer. Time to install Linux.

## Step 6: Configure VM Settings (Important!)

Before starting the VM, let's optimize some settings.

1. **Select your VM** in the VirtualBox main window
2. **Click "Settings"** (the orange gear icon)

### System Settings

**Processor tab:**

- **Processor(s):** Set to 2 CPUs (or half your total cores)
- Enables "Enable PAE/NX"

**Acceleration tab:**

- Make sure "Enable VT-x/AMD-V" is checked
- Make sure "Enable Nested Paging" is checked

### Display Settings

**Screen tab:**

- **Video Memory:** Slide to maximum (128 MB)
- **Graphics Controller:** VBoxSVGA
- **Enable 3D Acceleration:** Check this box (makes desktop smoother)

### Storage Settings

**Controller: IDE** (or SATA):

- Click the "Empty" CD icon under "Controller: IDE"
- On the right side, click the tiny CD icon next to "Optical Drive"
- Select "Choose a disk file..."
- **Browse to and select your downloaded Ubuntu ISO**

This "inserts" the Ubuntu installation disc into your virtual machine's virtual CD drive. Meta.

### Network Settings (Optional but Recommended)

**Adapter 1 tab:**

- "Attached to:" should be "NAT" (default)
- Click "Advanced"
- Click "Port Forwarding"
- This is where you'd add SSH access later (we'll skip for now)

**Click "OK"** to save all settings.

## Step 7: Install Ubuntu

Time for the fun part. Let's install Linux.

1. **Double-click your VM** in VirtualBox to start it
2. You'll see a VirtualBox window open - this is your virtual computer booting up

### Ubuntu Installer

After a moment, you'll see the Ubuntu installer:

1. **Try or Install Ubuntu**
   - Click "Install Ubuntu"

2. **Keyboard Layout**
   - Select your keyboard layout (usually auto-detected correctly)
   - Click "Continue"

3. **Updates and Other Software**
   - Select "Normal installation"
   - **Check** "Download updates while installing Ubuntu"
   - **Check** "Install third-party software..." (for better hardware support)
   - Click "Continue"

4. **Installation Type**
   - Select "Erase disk and install Ubuntu"
   - **Don't panic** - this is the *virtual* disk, not your real computer!
   - Click "Install Now"
   - Confirmation popup - click "Continue"

5. **Where Are You?**
   - Select your timezone (usually auto-detected)
   - Click "Continue"

6. **Who Are You?**
   - **Your name:** Your actual name (displayed at login)
   - **Computer's name:** ubuntu-vm (or whatever you want)
   - **Username:** your username (lowercase, no spaces)
   - **Password:** Choose a password (you'll type this a lot - make it simple for a VM)
   - Select "Log in automatically" (this is a local VM, security is less critical)
   - Click "Continue"

### Installation Progress

The installer will now:

- Copy files (~10-15 minutes)
- Install system
- Configure system

Grab coffee. Read the Ubuntu feature slideshow. Marvel at how far Linux desktops have come.

### Finish Installation

When you see "Installation Complete":

1. Click "Restart Now"
2. You might see "Please remove installation medium, then press ENTER"
   - VirtualBox usually auto-ejects the ISO
   - Just press ENTER in the VM window

The VM will reboot, and you'll see the Ubuntu login screen (or desktop if you chose auto-login).

**Congratulations!** You just installed Linux.

## Step 8: Post-Install Tweaks

### Install VirtualBox Guest Additions

This is crucial - Guest Additions dramatically improve the VM experience:

- Better video support
- Seamless mouse integration
- Shared clipboard (copy/paste between host and VM)
- Shared folders
- Auto-resize display

**To install:**

1. **In the VirtualBox window menu:** Devices → Insert Guest Additions CD image...
2. Ubuntu will prompt to run the installer - click "Run"
3. Enter your password
4. Terminal window opens showing installation progress
5. When it says "Press Return to close this window," press Enter
6. **Restart the VM:** Click the power icon → Restart

After reboot:

- **Mouse should flow freely** between host and VM (no more clicking to "capture")
- **Window should resize dynamically** - make VirtualBox window bigger, Ubuntu desktop follows
- **Clipboard sharing works** - copy text on Windows/Mac, paste in Linux and vice versa

### Enable Shared Folders (Optional)

To share files between your host OS and the VM:

1. **In VirtualBox main window** (with VM shut down): Settings → Shared Folders
2. Click the folder+ icon
3. **Folder Path:** Browse to a folder on your host OS (e.g., "C:\Users\YourName\LinuxShare")
4. **Folder Name:** LinuxShare
5. Check "Auto-mount"
6. Click "OK"

Start the VM. The shared folder will appear at `/media/sf_LinuxShare`.

To access it without sudo:

```bash title="Add your user to vboxsf group"
sudo usermod -aG vboxsf $USER
```

Log out and back in for changes to take effect.

## Step 9: Take a Snapshot

This is where VirtualBox becomes magical.

A **snapshot** is a save point. You can restore your VM to this exact state anytime. Break something experimenting? Restore snapshot. Want to test dangerous commands? Take snapshot first.

**To create a snapshot:**

1. **With the VM running or shut down:** Machine → Take Snapshot (or click the hamburger menu → Snapshots)
2. **Snapshot Name:** "Fresh Install" or "Clean Ubuntu 24.04"
3. **Description:** "Clean installation before any configuration"
4. Click "OK"

**To restore a snapshot:**

1. Machine → Tools → Snapshots
2. Select the snapshot
3. Click "Restore"

!!! tip "Snapshot Strategy"
    I take snapshots at key milestones:

    - "Fresh Install" - right after installation
    - "Configured" - after installing my tools and tweaking settings
    - "Before Major Upgrade" - before running apt upgrade
    - "Working State" - when everything's working perfectly

    Disk space is cheap. Peace of mind is priceless.

## Common Issues and Fixes

### "VT-x/AMD-V hardware acceleration is not available"

**Problem:** Virtualization isn't enabled in BIOS.

**Fix:** Restart computer, enter BIOS, enable VT-x or AMD-V. See Step 1.

### VM is incredibly slow

**Possible causes:**

1. **Not enough RAM allocated** - Go to Settings → System, allocate more RAM (but stay in green)
2. **Not enough host RAM** - Close other applications, or get more RAM
3. **Guest Additions not installed** - See Step 8
4. **Disk is full** - Check both host and guest disk space

### Mouse gets "captured" and won't leave VM

**Problem:** Guest Additions aren't installed or aren't working.

**Fix:** Install Guest Additions (Step 8). Until then, press the "Host Key" (usually Right Ctrl) to release mouse.

### Shared clipboard doesn't work

**Problem:** Guest Additions not installed or settings wrong.

**Fix:**

1. Install Guest Additions (Step 8)
2. In VirtualBox window: Devices → Shared Clipboard → Bidirectional

### Display won't resize with window

**Problem:** Guest Additions not installed or 3D acceleration disabled.

**Fix:**

1. Install Guest Additions (Step 8)
2. Settings → Display → Enable 3D Acceleration

### "This kernel requires an x86-64 CPU, but only detected an i686 CPU"

**Problem:** You're booting a 64-bit Ubuntu ISO but VirtualBox is in 32-bit mode.

**Fix:** Virtualization isn't enabled. See Step 1. After enabling VT-x/AMD-V, create a new VM and select "Ubuntu (64-bit)" as the version.

## What's Next?

Your VM is ready. Ubuntu is installed. Guest Additions are working. You took a snapshot. You're ready to learn Linux.

But where do you start? Head over to **[Post-Install Essentials](post_install.md)** to update your system, install some useful tools, and get oriented.

After that, dive into **[Level 1: Everyday Navigation](../level_1/overview.md)** to learn the command-line basics you'll use hundreds of times a day.

## Key Takeaways

- **VirtualBox provides a risk-free Linux environment** - your main OS is completely safe
- **Snapshots are your safety net** - take them before trying anything risky
- **Guest Additions are essential** - don't skip this step
- **Start with Ubuntu LTS** - stable, well-supported, great for learning
- **Allocate adequate resources** - at least 4GB RAM, 50GB disk
- **Dynamic disk allocation is smart** - VM starts small, grows as needed

Virtual machines aren't just for beginners - I still use them constantly for testing, development, and learning new distributions. You've just built yourself a Linux laboratory where you can experiment freely.

The best way to learn Linux? Use it. Make mistakes. Break things. That's what snapshots are for.

Let's keep going.
