# WSL2 on Windows

!!! quote "Linux inside Windows in 5 minutes flat"

## The Windows Developer's Secret Weapon

For years, Windows developers who needed Linux tools had three bad options: dual-boot (annoying), virtual machines (slow), or Cygwin (imperfect compatibility). Then Microsoft did something surprising - they built a real Linux kernel into Windows.

**WSL2 (Windows Subsystem for Linux 2) is brilliant** for developers. Full Linux kernel, native performance, integrated with Windows. You get a proper Linux environment without leaving Windows, without rebooting, without the overhead of a VM.

This is the fastest way to get a Linux environment if you're on Windows. We're talking 5-10 minutes from decision to Linux command line.

## What WSL2 Actually Is

WSL2 runs a real Linux kernel using Hyper-V virtualization. It's not Wine (compatibility layer), not Cygwin (POSIX emulation), not a container - it's actual Linux.

**You get:**

- Real Linux kernel (not emulation)
- Full system call compatibility
- Excellent performance (faster than traditional VMs)
- Access to Windows files from Linux
- Access to Linux files from Windows (carefully)
- Integration with Visual Studio Code
- Docker Desktop support

**You don't get:**

- Linux GUI applications out-of-the-box (possible with extra setup)
- Linux kernel customization (Microsoft provides the kernel)
- Boot process control (no systemd by default, though you can enable it)
- Direct hardware access (USB devices, graphics cards)

**Bottom line:** Perfect for development, scripting, learning Linux CLI. Not ideal if you want to learn about Linux as an operating system (boot process, init systems, etc.).

## What You'll Need

**Windows requirements:**

- Windows 10 version 2004+ (Build 19041+) **or** Windows 11
- 64-bit processor
- 4GB RAM minimum (8GB+ recommended)
- Virtualization enabled in BIOS (usually enabled by default)
- Administrator access

**Check your Windows version:**

1. Press Win+R
2. Type `winver` and press Enter
3. Look for "Version" number - must be 2004 or higher

**Time needed:** 5-15 minutes (plus time for downloads)

## Installation (The Easy Way)

Microsoft finally made WSL2 installation trivial. One command, and you're done.

### Step 1: Open PowerShell as Administrator

1. Press Win key
2. Type "PowerShell"
3. **Right-click "Windows PowerShell"**
4. Click "Run as administrator"
5. Click "Yes" on the UAC prompt

### Step 2: Install WSL2

In the PowerShell window, type this command:

```powershell title="Install WSL2 with Ubuntu"
wsl --install
```

That's it. Seriously.

**What this does:**

- Enables WSL feature
- Enables Virtual Machine Platform feature
- Downloads the latest Linux kernel
- Sets WSL2 as default
- Installs Ubuntu (the default distribution)

You'll see progress as it downloads and installs components.

### Step 3: Restart Your Computer

When the installation completes:

```powershell title="Restart Windows"
Restart-Computer
```

Or just click Start → Power → Restart.

### Step 4: Set Up Ubuntu

After your computer restarts, Ubuntu will launch automatically (if it doesn't, search for "Ubuntu" in the Start menu).

You'll see a terminal window with "Installing, this may take a few minutes..."

Wait for it to complete, then:

1. **Enter a username:** (lowercase, no spaces)
   - This is your Linux username, doesn't have to match Windows username
   - Example: `john` or `jsmith`

2. **Enter a password:**
   - You'll type this often, so make it easy to type
   - Linux won't show characters as you type (not even asterisks) - this is normal
   - Type it, press Enter
   - Type it again to confirm, press Enter

**Congratulations!** You now have Linux on Windows.

You'll see a bash prompt:

```
username@COMPUTERNAME:~$
```

## Installation (Manual Method)

If `wsl --install` doesn't work (older Windows versions), here's the manual process:

### Enable WSL Feature

```powershell title="Enable Windows Subsystem for Linux"
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
```

### Enable Virtual Machine Platform

```powershell title="Enable Virtual Machine feature"
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

### Restart

```powershell
Restart-Computer
```

### Download and Install Linux Kernel Update

After restart:

1. Go to: [https://aka.ms/wsl2kernel](https://aka.ms/wsl2kernel)
2. Download "WSL2 Linux kernel update package"
3. Run the installer

### Set WSL2 as Default

```powershell title="Set WSL version 2 as default"
wsl --set-default-version 2
```

### Install a Linux Distribution

Open Microsoft Store, search for "Ubuntu", click "Get" to install. Then launch it and follow Step 4 above.

## Accessing Your Linux Environment

You have several ways to open your WSL2 Linux:

### Windows Terminal (Recommended)

If you have Windows Terminal (comes with Windows 11, downloadable for Windows 10):

1. Open Windows Terminal
2. Click the dropdown arrow next to the + tab
3. Select "Ubuntu"

Or just click the + to open your default profile (can set Ubuntu as default in settings).

### Ubuntu App

Search for "Ubuntu" in Start menu, click to launch.

### From Any PowerShell/Command Prompt

Type:

```bash
wsl
```

This drops you into your default Linux distribution.

### From Windows Explorer

In the address bar of any Explorer window, type:

```
\\wsl$
```

This shows all your installed WSL distributions as network locations. You can browse Linux files directly from Windows.

## First Commands to Try

Let's verify everything works:

```bash title="Check Linux distribution"
cat /etc/os-release
```

You should see Ubuntu version information.

```bash title="Check kernel version"
uname -r
```

You'll see something like `5.15.90.1-microsoft-standard-WSL2` - that's the Microsoft-built Linux kernel.

```bash title="Update package lists"
sudo apt update
```

This updates the list of available packages. You'll type your Linux password (the one you created earlier).

```bash title="Upgrade installed packages"
sudo apt upgrade -y
```

This updates all installed packages to their latest versions.

## Windows ↔ Linux Integration

This is where WSL2 shines. The integration between Windows and Linux is surprisingly good.

### Accessing Windows Files from Linux

Your Windows C: drive is mounted at `/mnt/c/`:

```bash title="List your Windows user folder"
ls /mnt/c/Users/$USER/
```

You can read and write Windows files from Linux:

```bash title="Create a file in Windows Documents"
echo "Hello from Linux!" > /mnt/c/Users/$USER/Documents/test.txt
```

Open Windows Explorer, go to Documents, and you'll see `test.txt`.

### Accessing Linux Files from Windows

**WARNING:** Don't modify Linux files using Windows tools (Notepad, etc.) - it can corrupt them.

**Safe way:**

- Use Windows Terminal or Visual Studio Code
- Or access via `\\wsl$\Ubuntu\home\your-username\`

**To open current Linux directory in Windows Explorer:**

```bash title="Open current folder in Explorer"
explorer.exe .
```

The `.exe` is important - tells WSL to run a Windows executable.

### Running Windows Commands from Linux

You can run Windows executables from Linux:

```bash title="Open Notepad from Linux"
notepad.exe
```

```bash title="Run PowerShell from Linux"
powershell.exe -Command "Get-Process"
```

```bash title="Ping using Windows ping"
ping.exe google.com
```

Note the `.exe` extension - this tells WSL you want the Windows version, not the Linux version.

### Running Linux Commands from Windows

In PowerShell or Command Prompt:

```powershell title="Run Linux commands from Windows"
wsl ls -la
wsl cat /etc/os-release
wsl uname -a
```

## Visual Studio Code Integration

If you use VS Code, the integration is phenomenal:

1. **Install VS Code** on Windows if you haven't already
2. **Install the "Remote - WSL" extension** in VS Code
3. In WSL terminal, navigate to a project folder:
   ```bash
   cd ~/my-project
   code .
   ```

VS Code will open with:

- Linux terminal integrated
- Linux filesystem access
- Extensions running in Linux context
- Git working in Linux

You're editing files in Linux, but using Windows VS Code. It's seamless.

## Upgrading WSL1 to WSL2

If you installed WSL before and have WSL1, upgrade to WSL2:

```powershell title="Check WSL version"
wsl --list --verbose
```

Look at the VERSION column. If it says 1, upgrade:

```powershell title="Convert to WSL2"
wsl --set-version Ubuntu 2
```

Replace "Ubuntu" with your distribution name if different.

Set WSL2 as default for future installs:

```powershell title="Set WSL2 as default"
wsl --set-default-version 2
```

## Installing Additional Distributions

Ubuntu is the default, but you can install others:

```powershell title="List available distributions"
wsl --list --online
```

You'll see Debian, Kali, openSUSE, etc.

```powershell title="Install a specific distribution"
wsl --install -d Debian
```

You can have multiple distributions installed simultaneously. Each is completely isolated.

## Common WSL2 Commands

```powershell title="List installed distributions"
wsl --list --verbose
```

```powershell title="Stop a running distribution"
wsl --terminate Ubuntu
```

```powershell title="Shut down all WSL instances"
wsl --shutdown
```

Useful if things get weird - shutting down WSL completely resets everything.

```powershell title="Set default distribution"
wsl --set-default Ubuntu
```

```powershell title="Uninstall a distribution"
wsl --unregister Debian
```

**Warning:** This deletes all data in that distribution. No recovery.

```powershell title="Export a distribution (backup)"
wsl --export Ubuntu C:\backup\ubuntu.tar
```

```powershell title="Import a distribution (restore)"
wsl --import Ubuntu C:\WSL\Ubuntu C:\backup\ubuntu.tar
```

## Configuration and Customization

### .wslconfig (Global Settings)

Create `C:\Users\YourUsername\.wslconfig` to control WSL2 resources:

```ini title=".wslconfig"
[wsl2]
memory=8GB         # Limit memory usage
processors=4       # Limit CPU cores
swap=2GB          # Swap file size
localhostForwarding=true  # Forward WSL ports to Windows
```

Restart WSL for changes to take effect:

```powershell
wsl --shutdown
```

### wsl.conf (Per-Distribution Settings)

Inside your Linux distribution, create `/etc/wsl.conf`:

```bash title="Edit wsl.conf"
sudo nano /etc/wsl.conf
```

```ini title="/etc/wsl.conf"
[boot]
systemd=true      # Enable systemd (Windows 11 or Windows 10 with recent update)

[automount]
root = /mnt/      # Where Windows drives mount
options = "metadata,umask=22,fmask=11"

[network]
generateHosts = true
generateResolvConf = true
```

Restart distribution:

```powershell
wsl --terminate Ubuntu
```

Then launch again.

## Common Issues and Fixes

### "WSL 2 requires an update to its kernel component"

**Fix:** Download kernel update from [https://aka.ms/wsl2kernel](https://aka.ms/wsl2kernel)

### "The virtual machine could not be started because a required feature is not installed"

**Fix:** Enable Virtual Machine Platform:

```powershell
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

Restart computer.

### WSL is incredibly slow when accessing Windows files

**Problem:** Cross-filesystem access (Linux → Windows or vice versa) has overhead.

**Fix:** Keep your project files in the Linux filesystem (`~/projects/`) for best performance. Access via `\\wsl$\Ubuntu\home\username\projects\` from Windows.

### Can't access network / internet from WSL

**Fix:** Try regenerating `/etc/resolv.conf`:

```bash
sudo rm /etc/resolv.conf
```

```powershell
wsl --shutdown
```

Restart WSL. If that doesn't work, manually set DNS:

```bash title="Set Google DNS"
sudo nano /etc/resolv.conf
```

Add:
```
nameserver 8.8.8.8
nameserver 8.8.4.4
```

### "Access is denied" when running wsl commands

**Fix:** Run PowerShell as Administrator.

### systemd doesn't work

**Requirements:**

- Windows 11 or Windows 10 with KB5020030 update
- Add to `/etc/wsl.conf`:
  ```ini
  [boot]
  systemd=true
  ```
- Restart: `wsl --terminate Ubuntu`

## What's Next?

Your WSL2 environment is ready. You have Linux on Windows, integrated and fast.

Now what?

1. **Update your system:** We did this earlier with `sudo apt update && sudo apt upgrade`, but make this a habit

2. **Install development tools:** Check out **[Post-Install Essentials](post_install.md)** for recommended packages

3. **Learn the command line:** Head to **[Level 1: Everyday Navigation](../level_1/overview.md)** to master the basics

4. **Set up your workflow:** Install git, configure VS Code Remote-WSL, set up your dotfiles

## Key Takeaways

- **WSL2 is the fastest way to get Linux on Windows** - 5 minutes from zero to Linux
- **Real Linux kernel, not emulation** - full compatibility
- **Excellent Windows integration** - access files both directions, run executables both ways
- **Perfect for development** - VS Code integration is outstanding
- **Not a full Linux experience** - no boot process, limited hardware access
- **Keep project files in Linux filesystem** - much faster than accessing Windows files
- **Multiple distributions supported** - run Ubuntu, Debian, Kali simultaneously

WSL2 has changed Windows development. You no longer need to dual-boot or run slow VMs. You have a real Linux environment integrated into Windows, and it's fast, well-supported, and actively developed.

For learning Linux commands, scripting, development tools, and server administration - this is an excellent environment.

Let's keep learning.
