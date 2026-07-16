---
date: "2026-02-03 21:52"
title: Getting Access to Linux
description: Set up your first Linux environment via SSH or a local VM. Step-by-step guidance to get safely connected and ready to start exploring your new system.
---

# Getting Access to Linux

!!! tip "Part of Day One"
    This is the first practical article in the [Day One: Getting Started](overview.md) series. If you're new to Linux, start there for the full roadmap.

Before you can explore Linux, you need access to a Linux environment. There are two main scenarios:

- **Scenario A:** Someone gave you SSH credentials to an existing server
- **Scenario B:** You need to set up your own Linux environment for learning

Pick your scenario below, complete the setup, then meet us at the [validation checkpoint](#validation-checkpoint).

---

=== "Scenario A: SSH to Existing Server"

    ## Connecting via SSH

    Someone just handed you SSH credentials to a Linux server. Maybe it's an IP address scrawled on a sticky note, maybe it's in a Slack message, maybe it's buried in your onboarding docs. Let's get you connected.

    SSH (Secure Shell) is how you connect to remote Linux servers. It's encrypted, it's standard, and once you've done it a few times, it becomes second nature.

    ### What You'll Need

    Before you connect, make sure you have:

    - **Hostname or IP address** — `192.168.1.100` or `server.example.com`
    - **Username** — your account name on the server
    - **Password** — your login password

    ### Choose Your Platform

    === "Linux / macOS"

        Good news: SSH comes pre-installed on every Linux distribution and macOS. Open your terminal and you're ready to go.

        ``` bash title="SSH Connection Command" linenums="1"
        ssh username@hostname
        ```

        Real example:

        ``` bash title="Connecting to a Server" linenums="1"
        ssh jsmith@192.168.1.100
        # or
        ssh jsmith@staging.example.com
        ```

        **What happens next:**

        1. First time connecting? You'll see a fingerprint warning — type `yes`
        2. Enter your password when prompted (nothing echoes to screen — that's normal)
        3. You're in

        !!! tip "Server Requires SSH Keys?"
            If you're getting "Permission Denied (Publickey)" errors, see the Troubleshooting section below. SSH key setup will be covered in a future article.

    === "Windows"

        Windows has a few options for SSH. Pick the one that matches your setup:

        === "Windows Terminal (Recommended)"

            Windows 10/11 includes OpenSSH by default. This is the easiest and most modern approach.

            Open Windows Terminal (or PowerShell) and use the same SSH commands:

            ``` bash title="SSH from Windows Terminal" linenums="1"
            ssh username@hostname
            ```

            Real example:

            ``` bash title="Connecting to a Server" linenums="1"
            ssh jsmith@192.168.1.100
            # or
            ssh jsmith@staging.example.com
            ```

            **What happens next:**

            1. First time connecting? You'll see a fingerprint warning — type `yes`
            2. Enter your password when prompted (nothing echoes to screen — that's normal)
            3. You're in

            Same syntax and behavior as Linux/Mac.

        === "PuTTY"

            PuTTY has been the Windows SSH client for decades. It's GUI-based and still popular.

            **Download:** [PuTTY official site](https://www.putty.org/)

            **How to connect:**

            1. Open PuTTY
            2. Enter your hostname or IP address
            3. Set port to 22 (or your custom port)
            4. Set connection type to "SSH"
            5. Click "Open"
            6. Enter your username when prompted
            7. Enter your password when prompted

            !!! tip "Server Requires SSH Keys?"
                If you're getting "Permission Denied (Publickey)" errors, see the Troubleshooting section below. SSH key setup for PuTTY will be covered in a future article.

        === "WSL"

            If you've installed Windows Subsystem for Linux, you've got full native SSH capabilities.

            Just open your WSL terminal (Ubuntu, Debian, etc.) and follow the **Linux / macOS** tab instructions above.

            This gives you the same experience as Linux users - SSH comes pre-installed and works identically.

    ### First Connection - The Fingerprint Warning

    The first time you connect to a server (regardless of platform), you'll see something scary:

    ```
    The authenticity of host '192.168.1.100 (192.168.1.100)' can't be established.
    ED25519 key fingerprint is SHA256:abc123def456...
    Are you sure you want to continue connecting (yes/no/[fingerprint])?
    ```

    SSH is asking you to verify the server's identity before trusting it — same concept as certificate pinning. Type `yes` to accept and store the fingerprint. SSH won't ask again unless the server's key changes (key rotation, rebuild, or rarely a MITM attempt worth investigating).

    ### SSH with a Specific Port

    Most SSH servers listen on port 22, but some use custom ports for security. If your server uses a different port:

    ``` bash title="SSH on Custom Port" linenums="1"
    ssh -p 2222 username@hostname  # (1)!
    ```

    1. `-p` sets the port number. Standard SSH uses port 22, but some servers use a non-standard port to reduce automated scanning. Your team will tell you if a custom port is required.

    ### Troubleshooting Common SSH Issues

    Running into connection problems? Expand the issue you're seeing:

    ??? question "Connection Refused"
        **What it means:** SSH can't reach the server at all.

        **Possible causes:**

        - Server might be down or unreachable
        - Firewall blocking port 22
        - Wrong IP address or hostname
        - Not connected to VPN (if required)

        **What to try:**

        ``` bash title="Test Basic Connectivity" linenums="1"
        ping hostname
        # or
        ping 192.168.1.100
        ```

        If ping fails, you have a network issue. Ask your team:

        - Is the server running?
        - Do I need VPN access?
        - Is this the correct hostname/IP?

    ??? question "Connection Timeout"
        **What it means:** SSH is trying to connect but getting no response.

        **Possible causes:**

        - Network issue - you might need to be on VPN
        - Server is on a private network you don't have access to
        - Firewall silently dropping packets

        **What to try:**

        - Check if you need to connect to VPN first
        - Verify you're on the correct network
        - Ask your team about network access requirements

    ??? question "Permission Denied (Publickey)"
        **What it means:** Server requires SSH key authentication instead of password.

        **Why this happens:**

        - Server is configured to only accept SSH keys (no password login)
        - Your public key hasn't been added to the server yet

        **What to do:**

        Contact your team - they'll either:

        - Enable password authentication for your account, or
        - Tell you their process for getting SSH access (ticket system, send public key to team lead, etc.)

        **Note:** SSH key setup is covered in a future article. For now, work with your team to get initial access.

    ??? question "Host Key Verification Failed"
        **What it means:** The server's fingerprint has changed since you last connected.

        **Why this happens:**

        - Server was rebuilt or reinstalled
        - Server's SSH keys were regenerated
        - Someone is trying to intercept your connection (rare but possible)

        **What to try:**

        ⚠️ **First, verify with your team** that the server was recently rebuilt or changed. Don't ignore this warning!

        If confirmed safe, remove the old fingerprint:

        ``` bash title="Remove Old Fingerprint" linenums="1"
        ssh-keygen -R hostname  # (1)!
        # or
        ssh-keygen -R 192.168.1.100
        ```

        1. `-R` removes the named host from `~/.ssh/known_hosts` — the file where SSH stores fingerprints it has previously accepted. Without clearing it, SSH will refuse the connection until the stale entry is gone.

        Then try connecting again. You'll see the fingerprint warning (as if it's your first connection).

=== "Scenario B: Set Up Your Own Environment"

    ## Setting Up Your Own Linux Environment

    You want to learn Linux but don't have a server to practice on? No problem. Pick the setup that matches your situation:

    === "VirtualBox/VMware (Recommended)"

        **Best for:** The best learning experience - full Linux with snapshots

        **Why this is recommended:** You get a complete Linux installation that you can break and restore in seconds. Perfect for learning.

        **How it works:** Linux runs in a virtual machine on your current OS (Windows, Mac, or Linux)

        **Setup time:** 30-60 minutes

        **Get started:**

        1. Download and install [VirtualBox (free)](https://www.virtualbox.org/)
        2. Download [Ubuntu Desktop ISO](https://ubuntu.com/download/desktop)
        3. Follow [Ubuntu's VM installation tutorial](https://ubuntu.com/tutorials/how-to-run-ubuntu-desktop-on-a-virtual-machine-using-virtualbox)

        | Pros | Cons |
        |------|------|
        | **Snapshots!** Break something? Roll back in seconds | Requires decent hardware (4GB+ RAM) |
        | Complete isolation from your main OS | Takes disk space (20GB+ for VM) |
        | Works on Windows, Mac, or Linux | Slightly longer initial setup |
        | Full Linux experience (desktop + terminal) | |
        | Safe environment to experiment | |

        **Hardware requirements:**

        - 4GB RAM minimum (8GB+ recommended)
        - 25GB free disk space
        - CPU with virtualization support (most modern CPUs)

    === "WSL2 (Windows Quick Start)"

        **Best for:** Windows users who want Linux immediately

        **How it works:** Linux runs inside Windows - full Linux terminal, native speed

        **Setup time:** 5-10 minutes

        **Get started:** [Microsoft's official WSL2 installation guide](https://learn.microsoft.com/en-us/windows/wsl/install)

        | Pros | Cons |
        |------|------|
        | Fastest setup - one command | Windows 10/11 only |
        | No separate VM needed | Not a complete server environment |
        | Access Windows and Linux files seamlessly | No desktop environment (terminal only) |
        | Perfect for development work | |

        **When to choose this:**

        - You're on Windows and want to start immediately
        - You primarily need the Linux command line
        - You don't need a full GUI desktop

    === "Cloud Provider"

        **Best for:** Real server experience, accessible from anywhere

        **How it works:** Cloud provider gives you a small Linux server for free (with limitations and time restrictions)

        **Setup time:** 15-30 minutes

        **Get started:** Most major cloud providers offer free tiers - search for "free tier" at your preferred provider. You'll create an account, launch an instance, and SSH to it.

        | Pros | Cons |
        |------|------|
        | Real server environment | Requires credit card (even for free tier) |
        | Access from anywhere | Watch for costs after free period |
        | Learn cloud concepts | Requires internet connection |
        | No hardware requirements | SSH access only (no desktop GUI) |

        **Important:** Set up billing alerts immediately to avoid surprise charges when free period ends.

    === "Physical Install"

        **Best for:** People with a spare machine or ready to commit to dual-boot

        **How it works:** Install Linux directly on hardware (dedicated machine or dual-boot)

        **Setup time:** 1-2 hours

        **Get started:** [Ubuntu installation guide](https://ubuntu.com/tutorials/install-ubuntu-desktop)

        | Pros | Cons |
        |------|------|
        | Full native performance | Dual-boot can be tricky (backup first!) |
        | Complete Linux experience | No easy rollback if you break something |
        | No virtualization overhead | Requires compatible hardware |
        | Can repurpose old hardware | More commitment than other options |

        **Best use case:** You have an old laptop/desktop you can dedicate to Linux learning.

        !!! tip "Have a Raspberry Pi?"
            If you already own a Raspberry Pi, that's a great learning platform! Affordable (~$50-100), low power, and perfect for hands-on Linux learning.

            - [Raspberry Pi official documentation](https://www.raspberrypi.com/documentation/)
            - Note: Pi uses ARM architecture, which differs from typical x86 servers — though ARM is increasingly common in enterprise environments (AWS Graviton, Ampere cloud instances), so skills learned here transfer directly to modern production work
            - Great for projects beyond just learning Linux

    ### Why We Recommend VMs

    Virtual machines (VirtualBox/VMware) offer the best learning experience because:

    - **Snapshots** - Take a snapshot before trying something risky, roll back if needed
    - **Safe experimentation** - Break things without consequences
    - **Full Linux** - Desktop + terminal, complete experience
    - **Professional relevance** - Many professionals use VMs for testing

    All options will get you to the same Linux command line. Pick what fits your situation.

---

## Validation Checkpoint

Regardless of which path you took (SSH into a server or set up your own environment), let's verify you're ready to continue.

**Open your Linux terminal and run these commands:**

``` bash title="Validation Test" linenums="1"
whoami
# jsmith

pwd
# /home/jsmith

ls
# Documents  Downloads  projects
```

**What these commands tell you:**

- `whoami` - Confirms your username (here: `jsmith`). This is your identity on the system.
- `pwd` - Shows your current location in the filesystem (here: your home directory `/home/jsmith`). You start here when you log in.
- `ls` - Lists what's in your current directory. An empty result is fine - it just means your home directory is empty.

**If all three run without errors, you're in and the environment is functional.**

---

## Practice Problems

??? question "Problem 1: Check Your SSH Environment"
    You're connected. Run the following and interpret what each tells you about the server:

    ``` bash title="Environment Snapshot" linenums="1"
    whoami && id && hostname && uptime
    ```

    What's your privilege level? Are you in `sudo` or `wheel`? What's the server's load?

    ??? tip "Answer"
        `whoami` gives your username. `id` shows all your group memberships — look for `sudo` or `wheel` to know if you have elevated privileges. `hostname` confirms which server you're on (critical on shared infrastructure). `uptime` shows how long the server has been running and the load average — you'll learn how to interpret load in the next article.

??? question "Problem 2: Find Hidden SSH Configuration"
    Run `ls -la ~` and look at what's in your home directory. Is there an `.ssh` directory? What's in it?

    ??? tip "Answer"
        ``` bash title="Inspect SSH Directory" linenums="1"
        ls -la ~
        ls -la ~/.ssh 2>/dev/null || echo "No .ssh directory yet"  # (1)!
        ```

        1. `2>/dev/null` suppresses the error if `.ssh` doesn't exist yet. `||` runs the `echo` only when the preceding command fails — a standard shell pattern for providing a fallback when a path may not exist.

        If `.ssh` exists, it may contain `authorized_keys` (public keys allowed to log in as you), `known_hosts` (servers you've connected to), and `config` (connection shortcuts). If you're on a fresh account, it may be empty or absent — it gets created when you first use key-based auth.

## What's Next?

You're in. You've got a Linux terminal in front of you. Now what?

Head to **[First 60 Seconds: Orientation](orientation.md)** to learn what to do immediately after logging in—checking who you are, what server you're on, and what resources are available.

The next articles in Day One will also cover:

- **[Understanding Your Permissions](permissions.md)** - Know what you're allowed to do on the server
- **[Safe Exploration](safe_exploration.md)** - How to look around without breaking things
- **[Reading Logs Like a Pro](reading_logs.md)** - Using `tail`, `grep`, and `journalctl` to understand what the system is telling you

For now, try the Practice Problems above to build familiarity with your new Linux environment.

---

## Further Reading

### Command References

- `man ssh` - Complete SSH manual; covers all connection options and flags
- `man ssh_config` - Configuration file format for persistent SSH connection settings

### Official Documentation

- [OpenSSH official documentation](https://www.openssh.com/manual.html) - Comprehensive SSH reference
- [SSH Academy](https://www.ssh.com/academy/ssh) - SSH concepts and best practices

### Related Articles

- [Orientation](orientation.md) - What to do immediately after you've connected
- [Understanding Your Permissions](permissions.md) - Know what you're allowed to do on the server

