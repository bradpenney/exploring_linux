# Post-Install Essentials

!!! quote "Your Linux is installed - now let's make it useful"

## The Fresh Install Moment

You've got Linux running. Whether it's a VM, WSL2, Raspberry Pi, or physical installation - you're looking at a desktop or command prompt, thinking "Now what?"

**A fresh Linux install is like a new apartment.** It has the basics - walls, floors, electricity - but it's not quite livable yet. You need to unpack, organize, install the things you actually use.

This guide covers the essential post-installation steps that apply to almost every Linux setup. Update the system, install useful tools, configure basics, and get ready to actually use your new environment.

## Step 1: Update Everything

**First rule of a new Linux install: update immediately.**

Ubuntu (and most Linux distributions) release updates constantly - security patches, bug fixes, new package versions. Your installation ISO might be months old.

```bash title="Update package lists"
sudo apt update
```

This refreshes the list of available packages and their versions from Ubuntu's repositories.

```bash title="Upgrade installed packages"
sudo apt upgrade -y
```

This downloads and installs updates for everything currently installed. The `-y` flag automatically answers "yes" to prompts.

**Time:** 5-30 minutes depending on how old your ISO is and internet speed.

**Reboot after major updates:**

```bash title="Reboot the system"
sudo reboot
```

### Enable Automatic Security Updates (Recommended)

```bash title="Install unattended-upgrades"
sudo apt install unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
```

Select "Yes" to enable automatic security updates.

This ensures critical security patches install automatically in the background. You'll still need to manually update for major version upgrades.

## Step 2: Install Essential Command-Line Tools

Here are the tools I install on every Linux system, whether it's a server or desktop:

```bash title="Install essential CLI tools"
sudo apt install -y \
  curl \
  wget \
  git \
  vim \
  htop \
  tree \
  net-tools \
  build-essential \
  software-properties-common \
  ca-certificates \
  gnupg \
  lsb-release
```

**What these do:**

- **curl, wget** - Download files from the internet via command line
- **git** - Version control system (essential for any development)
- **vim** - Powerful terminal text editor (or use `nano` if you prefer)
- **htop** - Interactive process viewer (better than `top`)
- **tree** - Display directory structure as a tree
- **net-tools** - Networking utilities (ifconfig, netstat, etc.)
- **build-essential** - Compilers and build tools (gcc, make, etc.)
- **software-properties-common** - Manage software repositories
- **ca-certificates, gnupg, lsb-release** - Required for adding third-party repositories securely

##Step 3: Configure Git (If You'll Use It)

If you plan to do any development, configure git with your identity:

```bash title="Set git username and email"
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

```bash title="Set default branch name to main"
git config --global init.defaultBranch main
```

```bash title="Enable colored output"
git config --global color.ui auto
```

### Generate SSH Key for GitHub/GitLab

```bash title="Generate SSH key"
ssh-keygen -t ed25519 -C "your.email@example.com"
```

Press Enter to accept default location, then enter a passphrase (or leave empty for no passphrase).

```bash title="Display your public key"
cat ~/.ssh/id_ed25519.pub
```

Copy this and add it to your GitHub/GitLab account under Settings → SSH Keys.

## Step 4: Install Desktop Applications (Desktop Installs Only)

If you're running Ubuntu Desktop (not server), here are essential GUI applications:

### Productivity

```bash title="Install productivity apps"
sudo apt install -y \
  libreoffice \
  gimp \
  vlc \
  firefox
```

- **LibreOffice** - Full office suite (Word/Excel/PowerPoint equivalent)
- **GIMP** - Image editing (Photoshop alternative)
- **VLC** - Media player (plays everything)
- **Firefox** - Web browser (usually pre-installed)

### Development Tools

```bash title="Install development tools"
sudo apt install -y \
  code \                      # Visual Studio Code (if available)
  terminator \                # Advanced terminal emulator
  meld \                      # Visual diff tool
  dconf-editor                # Advanced system settings editor
```

**Note:** VS Code might not be in default repositories. Install from:

```bash title="Install VS Code via Snap"
sudo snap install code --classic
```

Or download `.deb` from [https://code.visualstudio.com](https://code.visualstudio.com):

```bash title="Install .deb file"
sudo dpkg -i ~/Downloads/code_*.deb
sudo apt install -f  # Fix dependencies if needed
```

### Communication

```bash title="Communication apps"
sudo snap install slack --classic
sudo snap install discord
sudo snap install zoom-client
```

### Utilities

```bash title="Useful utilities"
sudo apt install -y \
  gnome-tweaks \              # Customize GNOME desktop
  dconf-editor \              # Edit system settings
  gnome-shell-extensions \    # Desktop extensions support
  chrome-gnome-shell          # Browser extension support
```

## Step 5: Install Snap Support (If Not Already Installed)

Snap is Ubuntu's universal package format. Some applications are only available as Snaps.

```bash title="Install snapd"
sudo apt install snapd
```

Enable snap service:

```bash title="Enable snapd"
sudo systemctl enable --now snapd.socket
```

Test it:

```bash title="Install hello-world snap"
sudo snap install hello-world
hello-world
```

## Step 6: Enable Firewall

Ubuntu includes `ufw` (Uncomplicated Firewall) - a user-friendly firewall interface.

```bash title="Enable UFW"
sudo ufw enable
```

```bash title="Allow SSH (important for remote access!)"
sudo ufw allow ssh
```

```bash title="Check firewall status"
sudo ufw status
```

For desktops behind a home router, the firewall is less critical (your router provides network-level protection). For servers or laptops on public WiFi, it's essential.

### Common UFW Rules

```bash title="Allow HTTP/HTTPS (web server)"
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

```bash title="Allow specific port"
sudo ufw allow 8080/tcp
```

```bash title="Allow from specific IP"
sudo ufw allow from 192.168.1.100
```

```bash title="Deny specific port"
sudo ufw deny 23/tcp
```

## Step 7: Set Up Time Synchronization

Ensure your system clock is accurate:

```bash title="Install NTP"
sudo apt install systemd-timesyncd
```

```bash title="Enable time synchronization"
sudo timedatectl set-ntp true
```

```bash title="Check time status"
timedatectl status
```

Should show "System clock synchronized: yes".

## Step 8: Configure Timezone and Locale

### Set Timezone

```bash title="List available timezones"
timedatectl list-timezones | grep America
```

```bash title="Set timezone"
sudo timedatectl set-timezone America/New_York
```

Replace with your timezone.

### Set Locale (Language Settings)

```bash title="Check current locale"
locale
```

If you need to change it:

```bash title="Reconfigure locales"
sudo dpkg-reconfigure locales
```

Select your preferred locale (e.g., en_US.UTF-8) and set it as default.

## Step 9: Create a Useful Directory Structure

Organize your home directory for projects and work:

```bash title="Create project directories"
mkdir -p ~/projects/{personal,work,learning}
mkdir -p ~/bin  # For personal scripts
mkdir -p ~/documents
mkdir -p ~/downloads
```

Add `~/bin` to your PATH:

```bash title="Add ~/bin to PATH"
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Now any scripts in `~/bin` are available system-wide.

## Step 10: Customize the Shell (Optional)

### Install Zsh and Oh-My-Zsh (Popular Alternative to Bash)

```bash title="Install Zsh"
sudo apt install zsh
```

```bash title="Install Oh-My-Zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

This gives you a feature-rich shell with plugins, themes, and autocompletion.

### Or Customize Bash with Aliases

Add to `~/.bashrc`:

```bash title="Useful bash aliases"
# Add these to ~/.bashrc
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias update='sudo apt update && sudo apt upgrade -y'
alias install='sudo apt install'
alias remove='sudo apt remove'
alias search='apt search'
alias ports='netstat -tulanp'
```

Reload bashrc:

```bash
source ~/.bashrc
```

## Step 11: Set Up Backup Strategy

**Even for learning environments, backups are smart.**

### For Desktop: Timeshift (System Snapshots)

```bash title="Install Timeshift"
sudo apt install timeshift
```

Launch Timeshift from applications, configure:

- Snapshot type: RSYNC (simpler, works on any filesystem)
- Snapshot location: Select external drive or separate partition
- Schedule: Daily snapshots, keep 5

Take a snapshot of your fresh, configured system. If you break something later, restore to this point.

### For Important Data: Cloud Backup

```bash title="Install rclone (supports all major cloud providers)"
sudo apt install rclone
```

Configure for your cloud provider:

```bash
rclone config
```

Sync documents to cloud:

```bash title="Sync to cloud"
rclone sync ~/documents remote:documents
```

## Step 12: Install Additional Languages/Runtimes (As Needed)

Depending on what you're learning/building:

### Python

```bash title="Install Python 3 and pip"
sudo apt install python3 python3-pip python3-venv
```

### Node.js and npm

```bash title="Install Node.js via NodeSource"
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs
```

Verify:

```bash
node --version
npm --version
```

### Rust

```bash title="Install Rust via rustup"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env
```

### Go

```bash title="Install Go"
sudo apt install golang-go
```

### Docker

```bash title="Install Docker"
sudo apt install docker.io
sudo usermod -aG docker $USER
```

Log out and back in for group changes to take effect.

## Step 13: Clean Up

After all installations, clean up package cache:

```bash title="Remove unnecessary packages"
sudo apt autoremove -y
```

```bash title="Clean package cache"
sudo apt clean
```

## Desktop-Specific Tweaks (Ubuntu Desktop)

### Reduce Animations (For Older Hardware)

Settings → Accessibility → Reduce animation

### Enable Night Light (Reduce Blue Light)

Settings → Displays → Night Light → On

### Configure Power Settings

Settings → Power:

- Screen blank: 15 minutes
- Automatic suspend: 30 minutes (or Never for desktops)
- Show battery percentage (laptops)

### Install GNOME Extensions

Popular extensions:

- **Dash to Panel** - Windows-like taskbar
- **Vitals** - System monitor in top bar
- **Clipboard Indicator** - Clipboard history

Install via [https://extensions.gnome.org](https://extensions.gnome.org) after installing Chrome GNOME Shell:

```bash
sudo apt install chrome-gnome-shell
```

## Server-Specific Setup (Headless/Server Installs)

### Enable SSH (If Not Already Enabled)

```bash title="Install and enable SSH server"
sudo apt install openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh
```

### Harden SSH (Basic Security)

Edit SSH config:

```bash title="Edit SSH daemon config"
sudo nano /etc/ssh/sshd_config
```

Recommended changes:

```
PermitRootLogin no           # Disable root login via SSH
PasswordAuthentication yes   # Change to 'no' after setting up key-based auth
PubkeyAuthentication yes     # Enable SSH key authentication
Port 22                      # Change to non-standard port (e.g., 2222) for security through obscurity
```

Restart SSH:

```bash
sudo systemctl restart ssh
```

### Set Static IP (For Servers)

Edit netplan configuration (Ubuntu 18.04+):

```bash title="Edit netplan config"
sudo nano /etc/netplan/00-installer-config.yaml
```

Example static IP configuration:

```yaml
network:
  version: 2
  ethernets:
    eth0:  # Or your interface name (use 'ip a' to find it)
      dhcp4: no
      addresses:
        - 192.168.1.100/24
      gateway4: 192.168.1.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
```

Apply:

```bash
sudo netplan apply
```

## What's Next?

Your Linux system is now configured, updated, and ready for real use.

**Now what?**

1. **Learn the command line:** Head to **[Level 1: Everyday Navigation](../level_1/overview.md)** to master the basics

2. **Build something:** Set up a web server, start a programming project, configure a service

3. **Customize further:** Desktop themes, shell prompts, keyboard shortcuts, workflows

4. **Explore the ecosystem:** Discover new tools, try different applications, experiment

## Key Takeaways

- **Update immediately after installation** - fresh installs are outdated
- **Install essential CLI tools first** - curl, wget, git, vim, htop, tree
- **Configure git** - even if you're not developing yet, you'll need it
- **Enable firewall (ufw)** - simple one-time setup for ongoing security
- **Time synchronization matters** - especially for servers and development
- **Backups from day one** - Timeshift for system, rclone for data
- **Clean up regularly** - `apt autoremove` and `apt clean` free disk space

A well-configured Linux system is a joy to use. Take the time to set things up properly now, and you'll have a smooth experience going forward.

Every Linux user develops their own set of essential tools and configurations. This guide covers the universals - you'll discover your own preferences as you learn.

Let's keep building.
