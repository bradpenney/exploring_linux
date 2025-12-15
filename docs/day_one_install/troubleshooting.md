# Troubleshooting Common Issues

!!! quote "When things go wrong - and how to fix them"

## The Reality of Linux Installation

Let's be honest: **Linux installations don't always go smoothly.** A laptop with oddball WiFi hardware. A BIOS that fights USB boot. A partitioning mistake. A driver that won't load.

**This isn't a failure - it's part of the learning process.** Every Linux user has battle stories about installations that took hours to debug. The troubleshooting skills you develop now will serve you throughout your Linux journey.

This guide covers the most common installation and post-installation issues across all platforms, organized by problem type.

## Boot and Installation Issues

### "Operating system not found" or Black Screen After Installation

**Symptoms:** After installing Linux, computer won't boot. Shows error message or black screen.

**Most common cause:** Bootloader (GRUB) didn't install correctly or installed to wrong drive.

**Fix from Ubuntu Live USB:**

1. Boot from your Ubuntu installation USB
2. Select "Try Ubuntu"
3. Open terminal
4. Install Boot Repair:
   ```bash
   sudo add-apt-repository ppa:yannubuntu/boot-repair
   sudo apt update
   sudo apt install boot-repair
   ```
5. Run Boot Repair:
   ```bash
   boot-repair
   ```
6. Select "Recommended repair"
7. Follow on-screen instructions
8. Reboot

**Fix manually:**

```bash title="Reinstall GRUB manually"
sudo fdisk -l  # Find your Linux partition (usually /dev/sda1 or /dev/nvme0n1p2)
sudo mount /dev/sdaX /mnt  # Replace X with your partition number
sudo mount --bind /dev /mnt/dev
sudo mount --bind /proc /mnt/proc
sudo mount --bind /sys /mnt/sys
sudo chroot /mnt
grub-install /dev/sda  # Install GRUB to disk (not partition!)
update-grub
exit
sudo reboot
```

### Windows Disappeared from GRUB Menu

**Symptoms:** GRUB loads, but Windows isn't listed as a boot option.

**Cause:** GRUB didn't detect Windows partition during installation.

**Fix:**

```bash title="Regenerate GRUB configuration"
sudo os-prober
sudo update-grub
```

If `os-prober` is disabled:

```bash title="Enable os-prober"
sudo nano /etc/default/grub
```

Add this line at the end:
```
GRUB_DISABLE_OS_PROBER=false
```

Save and exit, then:

```bash
sudo update-grub
sudo reboot
```

### Can't Boot from USB - Computer Ignores It

**Possible causes:**

1. **USB not bootable** - Re-create using Rufus/Etcher
2. **Boot order wrong** - USB isn't first in BIOS boot order
3. **Secure Boot enabled** - Try disabling in BIOS
4. **Fast Boot enabled** - Disable in BIOS
5. **Wrong partition scheme** - GPT vs MBR mismatch

**Troubleshooting steps:**

1. **Verify USB is bootable:**
   - Recreate with Rufus (Windows) or Etcher (Mac/Linux)
   - For Rufus: Select "GPT" for UEFI systems, "MBR" for legacy BIOS

2. **Access BIOS/UEFI:**
   - Restart computer
   - Press F2, F10, F12, Del, or Esc during startup (varies by manufacturer)

3. **Check boot mode:**
   - Look for "UEFI" or "Legacy" mode
   - Match your USB partition scheme to boot mode

4. **Change boot order:**
   - Move USB to first position
   - Or use boot menu (F12/F9) to manually select USB

5. **Disable Secure Boot:**
   - Usually under "Security" or "Boot" tab
   - Set to "Disabled"
   - Save and exit

### Installation Freezes at "Installing System"

**Symptoms:** Installation hangs at copying files or configuring system.

**Possible causes:**

1. **Bad installation media** - Corrupted ISO or bad USB write
2. **Hardware compatibility** - Especially graphics drivers
3. **Insufficient RAM** - System swapping heavily
4. **Bad disk sectors** - Failing hard drive

**Fixes:**

**Try safe graphics mode:**

- At GRUB menu (when booting USB), select "Safe graphics"
- This loads basic graphics drivers, avoiding GPU issues

**Verify ISO checksum:**

```bash title="Check ISO integrity (Linux/Mac)"
sha256sum ubuntu-24.04-desktop-amd64.iso
```

Compare with checksum on Ubuntu's download page.

**Re-create USB:**

- Use different USB drive if possible
- Try different creation tool (Rufus vs Etcher)

**Check disk health:**

```bash title="Check disk from live USB"
sudo smartctl -H /dev/sda  # Replace sda with your disk
```

## Hardware Compatibility Issues

### WiFi Doesn't Work

**Symptoms:** WiFi adapter not detected or can't connect to networks.

**Most common cause:** Proprietary driver not installed.

**Identify WiFi hardware:**

```bash title="List WiFi hardware"
lspci | grep -i network
# Or for USB WiFi:
lsusb | grep -i wireless
```

Note the chip manufacturer (Broadcom, Realtek, Intel, etc.).

**Fix for Broadcom:**

```bash title="Install Broadcom drivers"
sudo apt update
sudo apt install bcmwl-kernel-source
sudo modprobe wl
```

Reboot.

**Fix for Realtek:**

```bash title="Install Realtek drivers"
sudo apt install rtl8188fu-dkms  # Or rtl8812au-dkms, etc.
```

Search for your specific chip (e.g., "RTL8821CE Ubuntu driver").

**Alternative: USB WiFi adapter:**

If built-in WiFi won't work, $15 USB WiFi adapters with better Linux support exist (look for ones that explicitly mention Linux compatibility).

### Graphics Issues - Low Resolution, Tearing, Flickering

**Symptoms:** Stuck at 1024x768, screen tearing, flickering, or black screen.

**For NVIDIA cards:**

```bash title="Install NVIDIA proprietary driver"
sudo ubuntu-drivers devices  # See available drivers
sudo ubuntu-drivers autoinstall  # Install recommended driver
sudo reboot
```

Or manually:

```bash
sudo apt install nvidia-driver-535  # Use version shown by 'devices' command
sudo reboot
```

**For AMD cards:**

Usually work out-of-box with open-source drivers. For better performance:

```bash
sudo apt install mesa-utils
```

**For Intel integrated graphics:**

Should work automatically. If not:

```bash
sudo apt install xserver-xorg-video-intel
```

**If stuck at black screen after driver install:**

Boot to recovery mode:

1. Restart
2. Hold Shift to show GRUB
3. Select "Advanced options"
4. Select recovery mode
5. Select "root - Drop to root shell"
6. Remove problematic driver:
   ```bash
   apt remove nvidia-*  # Or whatever driver you installed
   reboot
   ```

### Touchpad Not Working (Laptops)

**Symptoms:** Touchpad doesn't respond or partially works.

**Fix:**

```bash title="Install Synaptics driver"
sudo apt install xserver-xorg-input-synaptics
sudo reboot
```

**Enable tap-to-click:**

Settings → Mouse & Touchpad → Tap to Click

**Or via command:**

```bash
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
```

### Brightness Controls Don't Work (Laptops)

**Symptoms:** Fn+Brightness keys don't change screen brightness.

**Fix:**

Edit GRUB configuration:

```bash
sudo nano /etc/default/grub
```

Find the line:
```
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
```

Add kernel parameter (try one at a time):

**For Intel graphics:**
```
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash acpi_backlight=vendor"
```

**For NVIDIA:**
```
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash nvidia.NVreg_RegistryDwords=EnableBrightnessControl=1"
```

**Generic:**
```
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash acpi_osi=Linux"
```

Save, then:

```bash
sudo update-grub
sudo reboot
```

## Network and Connectivity Issues

### Can't Connect to Internet

**Wired (Ethernet):**

Usually works automatically. If not:

```bash title="Check if interface is detected"
ip link show
```

Look for `eth0`, `enp0s3`, or similar.

```bash title="Bring interface up"
sudo ip link set enp0s3 up  # Replace with your interface name
```

**Wireless (WiFi):**

See "WiFi Doesn't Work" section above.

**DNS not resolving:**

```bash title="Test DNS resolution"
ping 8.8.8.8  # Google's DNS - tests connectivity
ping google.com  # Tests DNS resolution
```

If first works but second doesn't, DNS issue:

```bash title="Set DNS manually"
sudo nano /etc/systemd/resolved.conf
```

Uncomment and set:
```
DNS=8.8.8.8 8.8.4.4
```

Restart:

```bash
sudo systemctl restart systemd-resolved
```

### SSH Connection Refused

**Symptoms:** `ssh: connect to host X.X.X.X port 22: Connection refused`

**Cause:** SSH server not running.

**Fix:**

```bash title="Install and enable SSH server"
sudo apt install openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh
```

**Check SSH status:**

```bash
sudo systemctl status ssh
```

Should show "active (running)".

**Check firewall:**

```bash
sudo ufw allow ssh
```

## Partition and Disk Issues

### "Not Enough Free Space" During Installation

**Symptoms:** Installer says not enough space, even though disk seems empty.

**Cause:** Windows recovery partitions, OEM partitions, or fragmented free space.

**Fix:**

From Windows (before installation):

1. Disk Management
2. Delete unnecessary recovery partitions (CAREFULLY)
3. Shrink Windows partition to create contiguous free space

From Ubuntu Live USB:

1. Use GParted:
   ```bash
   sudo apt install gparted
   sudo gparted
   ```
2. Resize/move partitions to create contiguous free space
3. Restart installer

### Can't Access Windows Files from Linux

**Symptoms:** Windows partition not visible or read-only.

**Cause:** Windows uses Fast Startup (hybrid sleep) which locks the filesystem.

**Fix:**

From Windows:

1. Control Panel → Power Options
2. "Choose what the power buttons do"
3. "Change settings currently unavailable"
4. Uncheck "Turn on fast startup"
5. Shut down (not restart)

From Linux:

```bash title="Mount Windows partition"
sudo mkdir /mnt/windows
sudo mount -t ntfs-3g /dev/sdaX /mnt/windows  # Replace X with partition number
```

If it's hibernated:

```bash title="Force mount (unsafe - may lose Windows data)"
sudo mount -t ntfs-3g -o remove_hiberfile /dev/sdaX /mnt/windows
```

Better: Boot Windows and fully shut down.

## Performance Issues

### System Running Slow

**Check disk space:**

```bash
df -h
```

If `/` (root) is >90% full, clean up:

```bash
sudo apt autoremove  # Remove old packages
sudo apt clean  # Clear package cache
journalctl --vacuum-size=100M  # Limit log size
```

**Check memory usage:**

```bash
free -h
htop  # Press F10 to quit
```

If swap is heavily used, you need more RAM or need to close applications.

**Check processes:**

```bash
top
# Or:
htop
```

Look for processes using high CPU/memory.

### Slow Boot Time

**Check boot time:**

```bash
systemd-analyze
systemd-analyze blame
```

This shows which services take longest to start.

**Disable unnecessary services:**

```bash title="Disable a slow service"
sudo systemctl disable service-name.service
```

## Package Management Issues

### "Unable to Locate Package"

**Symptoms:** `sudo apt install something` says package not found.

**Cause:** Package lists not updated or package not in repositories.

**Fix:**

```bash title="Update package lists"
sudo apt update
```

Then try installing again.

If still not found, package might need to be added from PPA or downloaded manually.

### "Unmet Dependencies" or "Broken Packages"

**Symptoms:** Can't install packages due to dependency conflicts.

**Fix:**

```bash title="Fix broken dependencies"
sudo apt --fix-broken install
sudo apt autoremove
sudo apt update
sudo apt upgrade
```

If that doesn't work:

```bash title="Nuclear option - reconfigure all packages"
sudo dpkg --configure -a
sudo apt clean
sudo apt update
```

## Dual-Boot Specific Issues

### Windows Time Wrong After Booting Linux

**Cause:** Windows uses local time for hardware clock, Linux uses UTC.

**Fix (from Linux):**

```bash
timedatectl set-local-rtc 1 --adjust-system-clock
```

This makes Linux use local time like Windows.

### GRUB Timeout Too Long/Short

**Change GRUB timeout:**

```bash
sudo nano /etc/default/grub
```

Change:
```
GRUB_TIMEOUT=10
```

To desired value (in seconds). 0 = skip menu.

Save, then:

```bash
sudo update-grub
```

## When All Else Fails

### Reinstall

Sometimes starting fresh is faster than debugging:

1. Back up `/home` (your personal files)
2. Reinstall Ubuntu
3. Restore `/home`

### Check Ubuntu Forums and Ask Ubuntu

- [https://ubuntuforums.org/](https://ubuntuforums.org/)
- [https://askubuntu.com/](https://askubuntu.com/)

Search for your specific error message and hardware.

### Check Logs

System logs contain error details:

```bash title="View system logs"
journalctl -xe  # Recent errors
dmesg | less   # Kernel messages
tail -f /var/log/syslog  # Live system log
```

## Key Takeaways

- **Most issues have been solved before** - search error messages
- **Hardware compatibility varies** - some hardware needs proprietary drivers
- **GRUB issues are fixable** - Boot Repair tool handles most cases
- **WiFi problems are common** - identify chip, install specific driver
- **Logs contain answers** - check `journalctl`, `dmesg`, `/var/log/`
- **When stuck, try safe graphics mode** - eliminates GPU driver issues
- **Backup before troubleshooting** - easy to restore if fixes make things worse

Troubleshooting Linux builds problem-solving skills. Every issue you fix teaches you more about how Linux works. The frustration is temporary - the knowledge is permanent.

Don't give up. Every experienced Linux user has been exactly where you are.

Let's keep learning.
