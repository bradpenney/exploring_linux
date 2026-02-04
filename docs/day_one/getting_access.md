# Getting Access to Linux

Before you can explore Linux, you need access to a Linux environment. There are two main scenarios, and we'll cover both.

**Pick your path:**

- **Scenario A:** Someone gave you SSH credentials to an existing server
- **Scenario B:** You need to set up your own Linux environment for learning

Read the section that matches your situation, then meet us at the [validation checkpoint](#validation-checkpoint) at the end.

---

## Scenario A: Connecting via SSH

Someone just handed you SSH credentials to a Linux server. Maybe it's an IP address scrawled on a sticky note, maybe it's in a Slack message, maybe it's buried in your onboarding docs. Let's get you connected.

SSH (Secure Shell) is how you connect to remote Linux servers. It's encrypted, it's standard, and once you've done it a few times, it becomes second nature.

### What You'll Need

Before you connect, make sure you have:

- **Hostname or IP address** - Where's the server? (`192.168.1.100` or `server.example.com`)
- **Username** - Who are you logging in as? (often your company username)
- **Credentials** - Either a password or an SSH key (we'll cover both)

### Connecting from Linux or Mac

Good news: SSH comes pre-installed on every Linux distribution and macOS. Open your terminal and you're ready to go.

``` bash title="SSH with Password"
ssh username@hostname
```

Real example:

``` bash title="Connecting to a Server"
ssh jsmith@192.168.1.100
# or
ssh jsmith@staging.example.com
```

**What happens next:**

1. First time connecting? You'll see a fingerprint warning (this is normal - type `yes`)
2. Enter your password when prompted
3. You're in! You should see the server's command prompt

### First Connection - The Fingerprint Warning

The first time you connect to a server, you'll see something scary:

```
The authenticity of host '192.168.1.100 (192.168.1.100)' can't be established.
ED25519 key fingerprint is SHA256:abc123def456...
Are you sure you want to continue connecting (yes/no/[fingerprint])?
```

**Don't panic.** This is SSH asking "Is this really the server you meant to connect to?"

Type `yes` and press Enter. SSH will remember this server and won't ask again (unless the server's key changes, which could indicate a security issue).

### SSH with a Specific Port

Most SSH servers listen on port 22, but some use custom ports for security. If your server uses a different port:

``` bash title="SSH on Custom Port"
ssh -p 2222 username@hostname
```

### Using SSH Keys Instead of Passwords

SSH keys are more secure and convenient than passwords. If someone gave you a private key file (usually named `id_rsa` or `something.pem`):

``` bash title="SSH with Key File"
ssh -i /path/to/private_key username@hostname
```

Example:

``` bash title="Using a Downloaded Key"
ssh -i ~/Downloads/my_server_key.pem ec2-user@server.example.com
```

!!! warning "Key File Permissions"
    SSH is picky about key file permissions. If you get a "permissions are too open" error:

    ``` bash title="Fix Key Permissions"
    chmod 600 /path/to/private_key
    ```

### Connecting from Windows

Windows has a few options for SSH. Let's cover them from easiest to most powerful.

**Option 1: Windows Terminal (Recommended)**

Windows 10/11 includes OpenSSH by default. Open Windows Terminal (or PowerShell) and use the same commands as Linux/Mac:

``` bash title="SSH from Windows Terminal"
ssh username@hostname
```

That's it! Same syntax, same behavior.

**Option 2: PuTTY (Traditional Approach)**

PuTTY has been the Windows SSH client for decades. It's GUI-based and still popular.

- **Download:** [PuTTY official site](https://www.putty.org/)
- Enter hostname/IP, port (22), connection type (SSH), click "Open"
- Enter username and password when prompted

**Note:** PuTTY uses `.ppk` format for keys. If you have a `.pem` file, you'll need to convert it using PuTTYgen (included with PuTTY).

**Option 3: WSL (Windows Subsystem for Linux)**

If you installed WSL, you've got full SSH capabilities. Just open your WSL terminal and use the Linux instructions above.

### Troubleshooting Common SSH Issues

**Connection Refused:**
- Server might be down, firewall blocking port 22, or wrong IP/hostname
- Try: `ping hostname` to test basic connectivity
- Ask your team: Is the server running? Do I need VPN access?

**Connection Timeout:**
- Network issue - check if you need to be on VPN
- Server might be on a private network you don't have access to

**Permission Denied (Publickey):**
- Server requires SSH key authentication
- Make sure you're specifying your key with `-i` flag
- Ask your team: Which key should I use? Has my public key been added?

**Host Key Verification Failed:**
- Server's fingerprint changed (maybe it was rebuilt?)
- Ask your team, then remove old fingerprint: `ssh-keygen -R hostname`

### Pro Tips for SSH Users

**Save time with SSH config:**

Create/edit `~/.ssh/config` to save common connections:

``` bash title="Example SSH Config"
Host staging
    HostName staging.example.com
    User jsmith
    Port 22
    IdentityFile ~/.ssh/my_key.pem

Host prod
    HostName 192.168.1.100
    User admin
    IdentityFile ~/.ssh/prod_key.pem
```

Now you can connect with just: `ssh staging`

**Keep connections alive:**

If your SSH session disconnects when idle, add this to `~/.ssh/config`:

```
Host *
    ServerAliveInterval 60
```

---

## Scenario B: Setting Up Your Own Linux Environment

You want to learn Linux but don't have a server to practice on? No problem. You've got several good options.

### Your Options (Pick One)

Here are the most popular approaches, with honest pros and cons:

#### 1. WSL2 (Windows Subsystem for Linux) - Easiest for Windows Users

**Best for:** Windows users who want Linux immediately, no reboot required

**How it works:** Linux runs inside Windows - full Linux terminal, native speed

**Setup time:** 5-10 minutes

**Get started:** [Microsoft's official WSL2 installation guide](https://learn.microsoft.com/en-us/windows/wsl/install)

**Pros:**
- Fastest setup - one command and you're running Linux
- No separate VM, no dual-boot complexity
- Access Windows and Linux files seamlessly
- Perfect for development work

**Cons:**
- Windows-only (obviously)
- Not a "real" server environment (no systemd in older versions)
- Requires Windows 10/11

#### 2. VirtualBox or VMware - Safest Learning Environment

**Best for:** Anyone who wants a full Linux experience with zero risk

**How it works:** Linux runs in a virtual machine on your current OS (Windows, Mac, Linux)

**Setup time:** 30-60 minutes (download + install + configure)

**Get started:**
- [VirtualBox (free)](https://www.virtualbox.org/)
- [Download Ubuntu Desktop ISO](https://ubuntu.com/download/desktop)
- [Ubuntu's VM installation tutorial](https://ubuntu.com/tutorials/how-to-run-ubuntu-desktop-on-a-virtual-machine-using-virtualbox)

**Pros:**
- Snapshots! Break something? Roll back in seconds
- Complete isolation from your main OS
- Works on any operating system
- Closest to a "real" Linux installation

**Cons:**
- Requires decent hardware (4GB+ RAM recommended)
- Slightly more setup than WSL2
- Takes disk space (20GB+ for the VM)

#### 3. Cloud Free Tier - Real Server Experience

**Best for:** Anyone who wants a "real" server environment accessible from anywhere

**How it works:** Cloud provider gives you a small Linux server for free (with limitations)

**Setup time:** 15-30 minutes (create account, launch instance, SSH in)

**Get started:**
- [Oracle Cloud Free Tier](https://www.oracle.com/cloud/free/) - Most generous, always free
- [AWS Free Tier](https://aws.amazon.com/free/) - 12 months free
- [Google Cloud Free Tier](https://cloud.google.com/free) - 90-day trial

**Pros:**
- Real server environment (not a VM on your laptop)
- Access from anywhere - phone, tablet, any computer
- Learn cloud concepts alongside Linux
- No hardware requirements

**Cons:**
- Requires credit card (even for free tier)
- Need to manage instance lifecycle (costs after free period)
- Requires internet connection
- SSH access only (no desktop GUI)

#### 4. Raspberry Pi - Physical Learning Device

**Best for:** People who already have a Raspberry Pi or want a dedicated Linux device

**Cost:** ~$50-100 for starter kit

**Get started:** [Raspberry Pi official documentation](https://www.raspberrypi.com/documentation/)

**Pros:**
- Physical device you can touch, disconnect, learn hardware with
- Low power consumption, can run 24/7
- Great for projects beyond just learning Linux

**Cons:**
- Costs money (though not much)
- ARM architecture (slightly different from typical x86 servers)
- Requires some hardware setup

#### 5. Physical Installation (Dual-Boot or Dedicated Machine)

**Best for:** People ready to commit, or have an old laptop/desktop to repurpose

**Get started:** [Ubuntu installation guide](https://ubuntu.com/tutorials/install-ubuntu-desktop)

**Pros:**
- Full native performance
- Complete Linux experience
- No virtualization overhead

**Cons:**
- Dual-boot can be tricky (backup your data!)
- No easy rollback if you break something
- Requires compatible hardware
- More commitment than other options

### Which Should You Choose?

**My recommendation for most learners:**

1. **Windows user?** → Start with WSL2 (easiest, fastest)
2. **Mac/Linux user wanting full Linux?** → Use VirtualBox (safest)
3. **Want real server experience?** → Oracle Cloud Free Tier (most realistic)

All of these will get you to the same place - a Linux terminal where you can learn. Pick what matches your comfort level and equipment.

### External Resources Are Your Friend

Notice I'm linking to official documentation rather than recreating installation tutorials? That's intentional. The official guides are:

- Always up-to-date (I can't maintain screenshots for 5 platforms)
- Comprehensive and well-tested
- Supported by the companies/communities behind them

When you hit issues, the official docs and forums are your best resource.

---

## Validation Checkpoint

Regardless of which path you took (SSH into a server or set up your own environment), let's verify you're ready to continue.

**Open your Linux terminal and run these commands:**

``` bash title="Validation Test"
whoami
# Should show your username

pwd
# Should show your current directory (probably /home/username)

ls
# Should list files (might be empty, that's fine!)
```

**If all three commands work, you're ready!**

You have a working Linux environment. Time to learn what to do with it.

---

## What's Next?

You're in. You've got a Linux terminal in front of you. Now what?

Head to **[First 60 Seconds: Orientation](orientation.md)** to learn what to do in those critical first moments - where you are, who you are, and what this system actually is.

!!! tip "Bookmark This Page"
    If you're using SSH or cloud instances, you might need to reconnect frequently. Bookmark this page so you can quickly reference connection commands.
