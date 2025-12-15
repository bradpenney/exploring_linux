# Raspberry Pi Setup

!!! quote "A $50 Linux computer you can hold in your hand"

## Why Raspberry Pi?

There's something satisfying about physical hardware. Virtual machines are great for learning, but they're abstract - you can't touch them, can't see the lights blink, can't show them off to friends.

**A Raspberry Pi is different.** It's a real computer, running real Linux, that costs about as much as dinner for two. You can set it up as a learning environment, a home server, a media center, a retro gaming console, or a thousand other projects.

This is my favorite way to learn Linux. The fact that it's separate hardware means you can experiment freely without risking your main computer. Plus, once you're done learning basics, you have a powerful little machine for projects.

## What is a Raspberry Pi?

A credit-card sized computer that runs Linux. Created by a UK charity to teach programming, it's become the most popular single-board computer in the world.

**You get:**

- ARM-based processor (similar to phones/tablets)
- 1-8GB RAM (depending on model)
- HDMI output (can connect to TV/monitor)
- USB ports for keyboard, mouse, storage
- WiFi and Bluetooth (on newer models)
- GPIO pins (control electronics directly)
- MicroSD card slot (this is your "hard drive")

**Most common models:**

- **Raspberry Pi 4** (4GB or 8GB) - the current flagship, ~$55-75
- **Raspberry Pi 5** (4GB or 8GB) - newest, faster, ~$60-80
- **Raspberry Pi Zero 2 W** - tiny, low-power, perfect for projects, ~$15

For learning Linux, **Raspberry Pi 4 (4GB)** is the sweet spot - powerful enough for desktop use, affordable, widely supported.

## What You'll Need

### Required Hardware

1. **Raspberry Pi board** (Pi 4 or Pi 5 recommended)
   - Buy from official distributors: CanaKit, Adafruit, PiShop.us
   - **Beware of counterfeits** on Amazon - stick with reputable sellers

2. **MicroSD card** (32GB+ recommended, Class 10 or better)
   - This is your storage - OS and all files live here
   - SanDisk and Samsung EVO cards work well
   - Don't cheap out - bad SD cards cause weird issues

3. **USB-C Power Supply** (Pi 4/5 need 5V 3A)
   - **Use the official Raspberry Pi power supply** - many USB chargers can't provide enough power
   - Underpowered Pis exhibit random crashes, WiFi drops, USB issues

4. **Way to flash the SD card**
   - USB SD card reader (if your computer doesn't have one)
   - ~$10 on Amazon

### Recommended Hardware

5. **Case** (~$5-10)
   - Protects the board
   - Many include heatsinks and fans
   - Not required but highly recommended

6. **Heatsinks or fan** (often included with cases)
   - Pi 4/5 can get warm under load
   - Passive heatsinks work for most use cases
   - Active cooling (fan) if you're going to stress it

### For Desktop Setup (Optional)

7. **Micro-HDMI to HDMI cable** (Pi 4/5 use micro-HDMI)
   - Pi 4/5 have TWO micro-HDMI ports (can run dual monitors!)
   - Standard HDMI cable won't fit

8. **USB keyboard and mouse**

9. **Monitor or TV** with HDMI input

### For Headless Setup (SSH Only)

If you're setting up the Pi to access remotely (no monitor), you just need:

- The Pi, power supply, SD card
- Another computer to SSH from
- Network connection (WiFi or Ethernet)

## Two Setup Paths

You can set up a Raspberry Pi two ways:

**Desktop Setup:**

- Pi connected to monitor, keyboard, mouse
- Traditional desktop Linux experience
- Great for learning, browsing, light office work
- Uses Raspberry Pi OS Desktop (Debian-based with LXDE desktop)

**Headless Setup:**

- Pi runs with no monitor (headless = no display)
- Access only via SSH from another computer
- Lighter weight, uses less power
- Perfect for servers, background tasks, learning server administration
- Uses Raspberry Pi OS Lite (no desktop environment)

**Which should you choose?**

- **Want to use it like a desktop computer?** → Desktop setup
- **Want a home server or learning SSH?** → Headless setup
- **Not sure?** → Desktop setup (you can always SSH into it too)

## Step 1: Download Raspberry Pi Imager

Raspberry Pi Foundation provides excellent software for flashing OS images to SD cards:

🔗 [https://www.raspberrypi.com/software/](https://www.raspberrypi.com/software/)

Download and install **Raspberry Pi Imager** for Windows, Mac, or Linux.

This tool:

- Downloads OS images for you
- Writes them to SD card
- Lets you preconfigure WiFi, SSH, user account
- Verifies the write completed successfully

Way easier than manually downloading images and using `dd` or Etcher.

## Step 2: Flash the SD Card

Insert your microSD card into your computer (via built-in reader or USB adapter).

**Open Raspberry Pi Imager:**

1. **Click "Choose Device"**
   - Select your Raspberry Pi model (e.g., "Raspberry Pi 4")

2. **Click "Choose OS"**

   **For desktop setup:**
   - Raspberry Pi OS (64-bit) - the first option
   - This includes the desktop environment

   **For headless setup:**
   - Scroll down to "Raspberry Pi OS (other)"
   - Select "Raspberry Pi OS Lite (64-bit)"
   - No desktop environment, just command line

3. **Click "Choose Storage"**
   - Select your microSD card
   - **DOUBLE-CHECK THIS** - wrong selection wipes wrong drive!

4. **Click "Next"**

5. **Click "Edit Settings"** (important!)

### OS Customization Settings

This is where the magic happens - you can preconfigure the Pi before first boot.

**General Tab:**

- **Set hostname:** `raspberrypi` (or something memorable like `piserver`)
- **Set username and password:**
  - Username: your choice (e.g., `pi`, `your name`)
  - Password: choose a password
  - **Note:** Newer Raspberry Pi OS versions don't have a default `pi` user for security
- **Configure WiFi:**
  - SSID: your WiFi network name
  - Password: your WiFi password
  - WiFi country: your country code (e.g., US, GB, CA)
- **Set locale settings:**
  - Timezone: your timezone
  - Keyboard layout: your layout

**Services Tab:**

- **Enable SSH:**
  - Check "Enable SSH"
  - Select "Use password authentication"
  - (You can use public-key authentication later if you want)

**Click "Save"**

**Click "Yes"** to apply OS customization settings.

**Click "Yes"** to confirm you want to erase the SD card.

The imager will:

- Download the OS image (if not cached)
- Write it to the SD card
- Verify the write
- Eject the card

**Time:** 5-15 minutes depending on SD card speed and internet connection.

## Step 3A: First Boot (Desktop Setup)

Eject the SD card from your computer.

1. **Insert microSD card** into the Raspberry Pi (card slot is on the underside)
2. **Connect micro-HDMI to monitor** (use Port 1, the one closest to the USB-C power port)
3. **Connect USB keyboard and mouse**
4. **Connect Ethernet** (optional - you configured WiFi in Imager)
5. **Connect power last** - the Pi boots immediately when powered

### First Boot Process

You'll see:

- Rainbow splash screen (Pi is booting)
- Lots of boot text scrolling (normal Linux boot messages)
- Raspberry Pi desktop environment loads

**First login:**

- Use the username and password you configured in Imager
- Desktop will load - looks like a lightweight version of Windows/Mac

### Initial Setup Wizard

The Pi will likely run a welcome wizard:

1. **Welcome** - Click "Next"
2. **Country** - Should be pre-set, verify and click "Next"
3. **Change Password** - Already set via Imager, skip or change if desired
4. **Setup Screen** - Adjust if you see black borders, click "Next"
5. **WiFi Network** - Should already be connected, click "Next"
6. **Update Software** - Click "Next" to check for updates
   - This downloads and installs updates (may take 10-20 minutes on first boot)
7. **Setup Complete** - Click "Restart"

After restart, you have a fully functional Linux desktop.

## Step 3B: First Boot (Headless Setup)

Eject the SD card from your computer.

1. **Insert microSD card** into Raspberry Pi
2. **Connect Ethernet** (optional - you configured WiFi)
3. **Connect power** - Pi boots automatically

The Pi will boot with no display. Give it 1-2 minutes to fully boot and connect to WiFi.

### Find the Pi on Your Network

You need the Pi's IP address to SSH to it.

**Method 1: Use hostname**

If you set hostname to `raspberrypi`, try:

```bash title="SSH using hostname"
ssh username@raspberrypi.local
```

Replace `username` with the username you configured in Imager.

**Method 2: Check your router**

Log into your router's admin interface and look at connected devices. Look for "raspberrypi" or a device from "Raspberry Pi Foundation".

**Method 3: Network scan (nmap)**

On Linux/Mac:

```bash title="Scan network for Raspberry Pi"
nmap -sn 192.168.1.0/24
```

Replace `192.168.1.0/24` with your network range. Look for Raspberry Pi Foundation in the MAC address.

On Windows, use Advanced IP Scanner (free tool).

### First SSH Connection

Once you have the IP address (let's say it's `192.168.1.42`):

```bash title="SSH to Raspberry Pi"
ssh username@192.168.1.42
```

First time connecting, you'll see:

```
The authenticity of host '192.168.1.42' can't be established.
ED25519 key fingerprint is SHA256:...
Are you sure you want to continue connecting (yes/no)?
```

Type `yes` and press Enter.

Enter your password.

**You're in!** You'll see the Raspberry Pi command prompt:

```
username@raspberrypi:~ $
```

## Step 4: Post-Setup Configuration

Whether desktop or headless, run these commands to ensure everything's up to date.

### Update the System

```bash title="Update package lists"
sudo apt update
```

```bash title="Upgrade all packages"
sudo apt upgrade -y
```

This may take a while on first boot - be patient.

### Expand Filesystem (Usually Automatic)

Modern Raspberry Pi OS auto-expands the filesystem to use your full SD card. Verify:

```bash title="Check disk space"
df -h
```

Look at the `/dev/root` line - should show most of your SD card size.

If it's only showing 2-4GB, manually expand:

```bash title="Run raspi-config"
sudo raspi-config
```

- Navigate to "Advanced Options"
- Select "Expand Filesystem"
- Reboot

### Run raspi-config for Additional Settings

```bash title="Open Raspberry Pi configuration tool"
sudo raspi-config
```

Useful settings:

**System Options:**

- **Wireless LAN** - Configure WiFi if you didn't in Imager
- **Password** - Change password
- **Hostname** - Change the Pi's network name

**Interface Options:**

- **SSH** - Enable/disable SSH (should already be enabled for headless)
- **VNC** - Enable VNC for remote desktop access
- **I2C, SPI** - Enable for hardware projects

**Performance Options:**

- **GPU Memory** - Default is fine for learning; increase if using desktop heavily

**Localization Options:**

- **Timezone** - Should be set from Imager
- **Keyboard** - Change keyboard layout if needed

**Advanced Options:**

- **Expand Filesystem** - Use full SD card capacity

**Use Tab key** to navigate, Enter to select, Esc to go back.

When done, select "Finish" and reboot if prompted.

## Step 5: Useful Post-Install Tweaks

### Enable VNC (Remote Desktop)

If you want to access the desktop remotely (for headless Pis or to access from another computer):

```bash title="Enable VNC via raspi-config"
sudo raspi-config
```

- Interface Options → VNC → Enable

Or via command line:

```bash title="Enable VNC"
sudo systemctl enable vncserver-x11-serviced
sudo systemctl start vncserver-x11-serviced
```

Download **VNC Viewer** on your computer from RealVNC, then connect to your Pi's IP address.

### Set Static IP Address

For headless Pis, a static IP makes SSH easier (no need to hunt for changing IP).

Edit the DHCP client configuration:

```bash title="Edit dhcpcd.conf"
sudo nano /etc/dhcpcd.conf
```

Add at the bottom:

```bash title="Static IP configuration"
interface wlan0  # Use eth0 for wired connection
static ip_address=192.168.1.100/24  # Choose an unused IP on your network
static routers=192.168.1.1          # Your router's IP
static domain_name_servers=192.168.1.1 8.8.8.8
```

Save (Ctrl+O, Enter) and exit (Ctrl+X).

Reboot:

```bash
sudo reboot
```

After reboot, Pi will always use that IP address.

### Install Useful Tools

```bash title="Install common utilities"
sudo apt install -y git vim htop curl wget tree
```

These are commonly needed for development and system administration.

## Common Issues and Fixes

### Rainbow screen, then nothing

**Problem:** Pi isn't booting from SD card.

**Fix:**

- Ensure SD card is fully inserted
- Re-flash the SD card using Imager
- Try a different SD card - cheap cards often fail

### Red LED on, green LED not blinking

**Problem:** Pi can't read SD card or OS image is corrupt.

**Fix:**

- Re-flash SD card
- Check SD card is seated properly
- Try different SD card

### WiFi won't connect

**Possible causes:**

1. **Wrong password** - Re-flash with Imager, double-check WiFi password
2. **5GHz network** - Pi 3 and older only support 2.4GHz WiFi
3. **WiFi country not set** - Run `sudo raspi-config`, Localization → WLAN Country

### Can't SSH to Pi

**Troubleshooting:**

1. **Is SSH enabled?** - If you didn't check it in Imager, you'll need monitor/keyboard to enable it
2. **Wrong IP address** - Check router for connected devices
3. **Firewall blocking** - Try from different computer
4. **Pi not on network** - Connect via Ethernet, then debug WiFi

### Pi running very slow, crashes randomly

**Problem:** Insufficient power supply.

**Fix:** Use official Raspberry Pi power supply (5V 3A for Pi 4/5). Many phone chargers can't provide enough current.

### "Under-voltage detected" warning icon

**Problem:** Power supply can't deliver enough power.

**Fix:** Replace with official Pi power supply or better quality power adapter.

### Can't login - wrong username/password

**Problem:** Credentials don't match what you configured in Imager.

**Fix:**

- Remember: newer Pi OS doesn't have default `pi` user
- Use the username/password you configured in Imager
- If all else fails, re-flash SD card with new credentials

## What's Next?

Your Raspberry Pi is up and running. You have a real Linux computer.

**Now what?**

1. **Learn the command line:** Head to **[Post-Install Essentials](post_install.md)** for tools to install, then **[Level 1: Everyday Navigation](../level_1/overview.md)** for command-line basics

2. **Use it as a server:** Set up Pi-hole (network-wide ad blocking), Nextcloud (personal cloud), or Plex (media server)

3. **Build projects:** Check out the official Raspberry Pi projects site for inspiration

4. **Learn Python:** Pi was designed for learning programming - Python comes pre-installed

5. **Experiment with GPIO:** Control LEDs, sensors, motors - physical computing!

## Key Takeaways

- **Raspberry Pi is real hardware running real Linux** - tangible, visible, fun
- **Two setup modes:** Desktop (with monitor) or headless (SSH only)
- **Raspberry Pi Imager makes setup easy** - preconfigure WiFi, SSH, user account
- **Use official power supply** - under-voltage causes weird issues
- **Quality SD card matters** - cheap cards cause random failures
- **Perfect for learning and projects** - low-risk, low-cost, versatile
- **ARM architecture** - most software works, some x86-only software won't

The Raspberry Pi community is huge and helpful. Whatever you want to do with your Pi, someone's probably done it and written a tutorial.

A Pi isn't just a learning tool - it's a gateway to endless projects. DNS server, retro gaming console, home automation controller, robot brain, network monitor, personal cloud - the list goes on.

Start with learning Linux. Build something cool later.

Let's keep going.
