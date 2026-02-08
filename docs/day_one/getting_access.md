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

    - **Hostname or IP address** - Where's the server? (`192.168.1.100` or `server.example.com`)
    - **Username** - Who are you logging in as? (often your company username)
    - **Password** - Your login password

    ### Choose Your Platform

    === "Linux / macOS"

        Good news: SSH comes pre-installed on every Linux distribution and macOS. Open your terminal and you're ready to go.

        ``` bash title="SSH Connection Command"
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

        ??? tip "Your Password Won't Show When You Type"
            When Linux asks for your password, **nothing appears on screen** - no characters, no asterisks, nothing.

            **Don't panic.** Your keyboard is working. Just type your password and press Enter. This is normal Linux behavior for security - it's not showing anything to prevent others from seeing how long your password is.

        !!! tip "Server Requires SSH Keys?"
            If you're getting "Permission Denied (Publickey)" errors, see the Troubleshooting section below. SSH key setup will be covered in a future article.

    === "Windows"

        Windows has a few options for SSH. Pick the one that matches your setup:

        === "Windows Terminal (Recommended)"

            Windows 10/11 includes OpenSSH by default. This is the easiest and most modern approach.

            Open Windows Terminal (or PowerShell) and use the same SSH commands:

            ``` bash title="SSH from Windows Terminal"
            ssh username@hostname
            ```

            Real example:

            ``` bash title="Connecting to a Server"
            ssh jsmith@192.168.1.100
            # or
            ssh jsmith@staging.example.com
            ```

            **What happens next:**

            1. First time connecting? You'll see a fingerprint warning (type `yes`)
            2. Enter your password when prompted
            3. You're in! You should see the server's command prompt

            ??? tip "Your Password Won't Show When You Type"
                When Linux asks for your password, **nothing appears on screen** - no characters, no asterisks, nothing.

                **Don't panic.** Your keyboard is working. Just type your password and press Enter. This is normal Linux behavior for security - it's not showing anything to prevent others from seeing how long your password is.

            That's it! Same syntax and behavior as Linux/Mac.

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

            ??? tip "Your Password Won't Show When You Type"
                When Linux asks for your password, **nothing appears on screen** - no characters, no asterisks, nothing.

                **Don't panic.** Your keyboard is working. Just type your password and press Enter. This is normal Linux behavior for security - it's not showing anything to prevent others from seeing how long your password is.

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

    **Don't panic.** This is SSH asking "Is this really the server you meant to connect to?"

    Type `yes` and press Enter. SSH will remember this server and won't ask again (unless the server's key changes, which could indicate a security issue).

    ### SSH with a Specific Port

    Most SSH servers listen on port 22, but some use custom ports for security. If your server uses a different port:

    ``` bash title="SSH on Custom Port"
    ssh -p 2222 username@hostname
    ```

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

        ``` bash title="Test Basic Connectivity"
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

        ``` bash title="Remove Old Fingerprint"
        ssh-keygen -R hostname
        # or
        ssh-keygen -R 192.168.1.100
        ```

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
            - Note: Pi uses ARM architecture, which differs slightly from typical x86 servers
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

``` bash title="Validation Test"
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

**If all three commands work, you're ready!**

You have a working Linux environment. Time to learn what to do with it.

---

## Practice Exercises

Now that you're connected, let's reinforce what you've learned.

??? question "Exercise 1: Test Your Connection"
    Practice connecting to your Linux environment using the method you chose.

    **Goal:** Successfully connect and run `whoami` to verify you're logged in.

    **For SSH users:** Try connecting, then disconnecting, then reconnecting to build familiarity.

    ??? tip "Solution"
        **SSH users:**

        ``` bash title="Connect to Your Server"
        ssh username@hostname
        # Enter your password when prompted
        ```

        Once connected:

        ``` bash title="Verify You're Logged In"
        whoami
        # Should show your username
        ```

        **Local setup users:**

        Just open your terminal (WSL, VirtualBox terminal, etc.) and run:

        ``` bash title="Verify Your Environment"
        whoami
        # Should show your username
        ```

??? question "Exercise 2: Understand Your Environment"
    Run the validation commands and interpret what each one tells you about your system.

    **Tasks:**

    1. Run `whoami` - What username are you using?
    2. Run `pwd` - Where in the filesystem are you?
    3. Run `ls -la` - What hidden files are in your home directory?

    ??? tip "Solution"
        ``` bash title="Explore Your Environment"
        whoami
        # Shows your current username

        pwd
        # Shows your current working directory (usually /home/yourusername)

        ls -la
        # Lists ALL files including hidden ones (starting with .)
        # You might see .bashrc, .profile, .ssh directory
        ```

        **What you learned:** The `-la` flags mean "long format" and "all files (including hidden)". Hidden files in Linux start with a dot.

---

## Further Reading

Want to dive deeper into SSH and connection options?

- `man ssh` - Complete SSH manual (run this in your terminal)
- `man ssh_config` - SSH configuration file format
- [OpenSSH official documentation](https://www.openssh.com/manual.html) - Comprehensive SSH reference
- [SSH Academy](https://www.ssh.com/academy/ssh) - SSH concepts and best practices

---

## What's Next?

You're in. You've got a Linux terminal in front of you. Now what?

Head to **[First 60 Seconds: Orientation](orientation.md)** to learn what to do immediately after logging in—checking who you are, what server you're on, and what resources are available.

The next articles in Day One will also cover:

- **[Safe Exploration](safe_exploration.md)** - How to look around without breaking things
- **Reading Logs** - Understanding what the system is telling you (coming soon)

For now, try the Practice Exercises above to build familiarity with your new Linux environment.

!!! tip "Bookmark This Page"
    If you're using SSH or cloud instances, you might need to reconnect frequently. Bookmark this page so you can quickly reference connection commands.
