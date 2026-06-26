---
date: "2025-08-13 21:28"
title: Linux Filesystem Hierarchy - Where Everything Lives
description: Understand the Linux filesystem hierarchy — where configuration, logs, binaries, and application data live, and why. The mental map every sysadmin needs.
---

# Linux Filesystem Hierarchy

!!! tip "Part of Essentials"
    This article assumes you're comfortable navigating the command line. If you haven't already, read [Command Line Fundamentals](command_line_fundamentals.md) first.

Inherit a new server. SSH in. Where's the config file? Where are the logs? Where did the team install that custom application?

On Windows, the answer depends on the vendor, the installer, and sometimes the mood of whoever set it up. On Linux, you already know — because the filesystem hierarchy is standardized. Once you have the map in your head, you'll know exactly where to look on any Linux system, any distribution, any server you'll ever touch.

That mental map is what this article builds.

---

## Where You've Seen This

If you've administered Windows servers, this maps directly: `/etc` is where service configuration lives (the Linux equivalent of the registry and `C:\ProgramData\` combined), `/home` is `C:\Users\`, `/var/log` is the Event Log data on disk, and `/opt` is `C:\Program Files\` for third-party software. The key difference: Linux makes the organizational boundary explicit and consistent by spec — the same layout on RHEL, Ubuntu, and Debian.

If you've worked with Docker or containers, you've already been inside this structure hundreds of times. Every container image uses the same FHS layout — which is why `nginx` config always lands at `/etc/nginx/nginx.conf` regardless of the base image.

If you've used any cloud provider's Linux instances (AWS, GCP, Azure), you've been here too. The first thing you do after SSH-ing in is `ls /etc/` and `cat /etc/os-release`. Now you'll know why.

---

## Why Everything Is in the Same Place

Linux distributions look different on the surface — different package managers, init systems, default software. But open a shell on RHEL, Ubuntu, Debian, or Arch and you'll find the same top-level directories in the same places.

That's not coincidence. It's the [Filesystem Hierarchy Standard](https://refspecs.linuxfoundation.org/FHS_3.0/fhs/index.html) (FHS), maintained by the Linux Foundation. Distributions that comply with FHS follow the same layout conventions, which means the skills you build on one system transfer directly to another.

### The Organizing Principle

Every directory in the Linux filesystem has a purpose category, and that category is consistent:

- **Configuration** that controls behavior → `/etc`
- **Data that changes during operation** (logs, state, cache) → `/var`
- **Installed software** (binaries, libraries, docs) → `/usr`
- **User-specific files** → `/home`
- **Third-party, self-contained apps** → `/opt`
- **Runtime data** (PIDs, sockets, disappears on reboot) → `/run`

The practical implication: when something isn't working, you check `/etc` for misconfiguration and `/var/log` for the error. When you need to find a binary, you check `/usr/bin`, `/usr/sbin`, or `/usr/local/bin`. You don't search — you know.

!!! tip "Why This Matters in Production"
    When production is down, you don't have time to search. An engineer who has this layout internalized goes straight to `/var/log/nginx/error.log` or `journalctl -u myapp`. Someone without it `find`s blindly and burns minutes they don't have. Knowing the hierarchy cold is the difference between a 5-minute diagnosis and a 30-minute one.

---

## The Map

Here's the top-level structure and what each section of the tree is for:

``` mermaid
graph LR
    ROOT["/\nFilesystem Root"] --> CONFIG["⚙️ /etc\nSystem Configuration"]
    ROOT --> VAR["📊 /var\nVariable Data"]
    ROOT --> USR["📦 /usr\nInstalled Software"]
    ROOT --> HOME["🏠 /home\nUser Home Directories"]
    ROOT --> OPT["🔧 /opt\nThird-Party Applications"]
    ROOT --> BOOT["🚀 /boot\nBoot Loader & Kernel"]
    ROOT --> VIRTUAL["👻 Virtual Filesystems\n/proc /sys /run /dev"]
    ROOT --> OTHER["📁 Other\n/tmp /srv /mnt /root"]

    VAR --> LOGS["/var/log\nLog Files"]
    VAR --> LIB["/var/lib\nApplication State"]
    VAR --> CACHE["/var/cache\nCached Data"]

    USR --> BIN["/usr/bin\nUser Binaries"]
    USR --> SBIN["/usr/sbin\nSystem Binaries"]
    USR --> LOCAL["/usr/local\nLocally Installed"]

    style ROOT fill:#d69e2e,stroke:#cbd5e0,stroke-width:2px,color:#000
    style CONFIG fill:#2d3748,stroke:#68d391,stroke-width:2px,color:#fff
    style VAR fill:#2d3748,stroke:#63b3ed,stroke-width:2px,color:#fff
    style USR fill:#2d3748,stroke:#fc8181,stroke-width:2px,color:#fff
    style HOME fill:#2d3748,stroke:#cbd5e0,stroke-width:2px,color:#fff
    style OPT fill:#2d3748,stroke:#d69e2e,stroke-width:2px,color:#fff
    style BOOT fill:#2d3748,stroke:#cbd5e0,stroke-width:2px,color:#fff
    style VIRTUAL fill:#1a202c,stroke:#718096,stroke-width:2px,color:#9ca3af
    style OTHER fill:#1a202c,stroke:#718096,stroke-width:2px,color:#fff
    style LOGS fill:#374151,stroke:#63b3ed,stroke-width:1px,color:#fff
    style LIB fill:#374151,stroke:#63b3ed,stroke-width:1px,color:#fff
    style CACHE fill:#374151,stroke:#63b3ed,stroke-width:1px,color:#fff
    style BIN fill:#374151,stroke:#fc8181,stroke-width:1px,color:#fff
    style SBIN fill:#374151,stroke:#fc8181,stroke-width:1px,color:#fff
    style LOCAL fill:#374151,stroke:#fc8181,stroke-width:1px,color:#fff
```

``` bash title="See It Yourself"
ls /
# bin   boot  dev  etc  home  lib  lib64  media  mnt  opt
# proc  root  run  sbin  srv  sys  tmp  usr  var
```

---

## The Directories That Matter Most

<div class="grid cards" markdown>

-   :material-cog: **/etc — System Configuration**

    ---

    **Why it matters:** This is where you make changes. Every service's configuration file lives here. Edit something in `/etc/` and it survives reboots — this is persistent, on-disk configuration.

    ``` bash title="What Lives in /etc"
    ls /etc/nginx/         # (1)!
    ls /etc/ssh/           # (2)!
    cat /etc/hosts         # (3)!
    cat /etc/fstab         # (4)!
    cat /etc/os-release    # (5)!
    ```

    1. nginx configuration.
    2. SSH server configuration.
    3. hostname to IP mappings.
    4. filesystem mount configuration.
    5. distribution identity.

    **Key insight:** When something isn't working, `/etc/` is where you look for misconfiguration. When you need to change behavior, `/etc/` is where you make the change.

-   :material-chart-line: **/var — Variable Data**

    ---

    **Why it matters:** Anything that changes during normal operation lives here. Logs, application state, package manager databases, mail spools. It's designed to grow over time.

    ``` bash title="What Lives in /var"
    ls /var/log/           # (1)!
    ls /var/lib/           # (2)!
    ls /var/cache/         # (3)!
    ls /var/spool/         # (4)!
    ```

    1. system and application logs.
    2. application state databases.
    3. cached package data.
    4. queued jobs (mail, print, cron).

    **Key insight:** `/var/log/` is your first stop when diagnosing problems. Disk space issues are almost always caused by `/var` growing unchecked — logs or databases.

-   :material-package: **/usr — Installed Software**

    ---

    **Why it matters:** The vast majority of executables, libraries, and documentation for installed packages lives here. It's meant to be read-only during normal operation — software goes in, the system reads it.

    ``` bash title="What Lives in /usr"
    ls /usr/bin/           # (1)!
    ls /usr/sbin/          # (2)!
    ls /usr/lib/           # (3)!
    ls /usr/local/bin/     # (4)!
    ls /usr/share/         # (5)!
    ```

    1. executables for all users (`ls`, `grep`, `cat`...).
    2. system admin executables (`sshd`, `nginx`, `iptables`...).
    3. shared libraries.
    4. locally installed executables (your scripts, custom tools).
    5. architecture-independent data, man pages.

    **Key insight:** If you install a tool from the package manager, its binary goes in `/usr/bin/`. If you compile something yourself or install it manually, put it in `/usr/local/bin/` — that directory won't be touched by system updates.

-   :material-folder-home: **/home and /root — User Directories**

    ---

    **Why it matters:** Every user gets a home directory. It's where personal files, shell configuration (`.bashrc`, `.ssh/`), and user-specific data live.

    ``` bash title="User Home Directories"
    ls /home/              # (1)!
    ls /home/jsmith/       # (2)!
    ls /root/              # (3)!

    echo $HOME             # (4)!
    cd ~                   # (5)!
    ```

    1. one directory per regular user.
    2. jsmith's files.
    3. root user's home (separate from `/home`).
    4. your home directory.
    5. shortcut to go home.

    **Key insight:** `/root` is the root user's home, not `/home/root`. It's intentionally separate. SSH keys live at `~/.ssh/authorized_keys` — finding these matters when you're debugging auth issues.

</div>

<div class="grid cards" markdown>

-   :material-application: **/opt — Third-Party Applications**

    ---

    **Why it matters:** Applications that don't follow the FHS layout — vendor software, self-contained apps, things not installed via the package manager — typically land here.

    ``` bash title="What Lives in /opt"
    ls /opt/               # (1)!
    # gitlab/   java/   splunk/   myapp/
    ```

    1. list installed third-party apps.

    **Key insight:** `/opt` is self-contained. Each application gets its own subdirectory with everything it needs. This makes it easy to install, upgrade, and remove without touching the rest of the system.

-   :material-rocket-launch: **/boot — Boot Loader and Kernel**

    ---

    **Why it matters:** The kernel image, initial RAM disk, and boot loader configuration live here. You rarely touch it directly, but you need to know it exists.

    ``` bash title="What Lives in /boot"
    ls /boot/
    # config-5.14.0-284.11.1.el9_2.x86_64
    # grub2/
    # initramfs-5.14.0-284.11.1.el9_2.x86_64.img
    # vmlinuz-5.14.0-284.11.1.el9_2.x86_64
    ```

    **Key insight:** Disk space issues in `/boot` happen on systems with many kernel versions installed. `rpm -q kernel` or `dpkg --list linux-image*` shows what's there; `dnf remove` or `apt autoremove` cleans old ones.

-   :material-server: **/srv — Service Data**

    ---

    **Why it matters:** Data served by the system — web server document roots, FTP content. Not every distribution uses this consistently, but it's worth knowing.

    ``` bash title="What Lives in /srv"
    ls /srv/               # (1)!
    ```

    1. often: `http/`, `ftp/`, or empty.

    **Key insight:** Some web servers default to `/var/www/html/` instead. Check the web server config in `/etc/nginx/` or `/etc/httpd/` to find where the document root actually is.

-   :material-harddisk: **/mnt and /media — Mount Points**

    ---

    **Why it matters:** Temporary and removable filesystems get mounted here. `/mnt` is for manually mounted filesystems (NFS shares, extra disks). `/media` is typically for auto-mounted removable media.

    ``` bash title="Checking Mounted Filesystems"
    mount | grep -v "^cgroup\|^sys\|^proc\|^dev"   # (1)!

    df -h   # (2)!
    ```

    1. Filters virtual mounts, shows real mounted filesystems.
    2. Shows disk usage for all mounted filesystems.

</div>

---

## Virtual Filesystems: The Exceptions

Not everything under `/` is on your hard drive. Several directories are **virtual filesystems** — they exist only in memory and are generated by the kernel at boot. They disappear when the system powers off.

!!! warning "Don't Write to Virtual Filesystems"
    Writing to `/proc` or `/sys` can change kernel behavior immediately — some changes are used intentionally (tuning kernel parameters via `/proc/sys/`), but doing so incorrectly can destabilize a running system. Never write to these directories unless you know exactly what you're doing.

| Directory | Type | What It Is |
|-----------|------|------------|
| `/proc` | Virtual (procfs) | Running processes, kernel state, hardware info — everything as files |
| `/sys` | Virtual (sysfs) | Kernel's view of hardware devices and drivers |
| `/run` | Virtual (tmpfs) | Runtime data: PID files, sockets, lock files — reset at boot |
| `/dev` | Virtual (devtmpfs) | Device files — your disks, terminals, random number generators |
| `/tmp` | Usually tmpfs | Temporary files — cleared on reboot (sometimes cleared on each boot) |

``` bash title="Reading from Virtual Filesystems (Safe)"
cat /proc/cpuinfo          # (1)!
cat /proc/meminfo          # (2)!
cat /proc/version          # (3)!

ls /proc/1234/             # (4)!
cat /proc/1234/cmdline     # (5)!

ls /sys/class/net/         # (6)!
```

1. CPU model, cores, flags.
2. detailed memory statistics.
3. kernel version string.
4. everything about process with PID 1234.
5. what command started that process.
6. network interfaces.

**The `/proc` trick:** Every running process has a directory at `/proc/PID/`. If you know a process's PID, you can read its open files (`/proc/PID/fd/`), environment variables (`/proc/PID/environ`), and more — all without any special tools.

---

## The Modern Symlink Consolidation

On modern systems (RHEL 7+, Ubuntu 20.04+, Debian 10+), you'll notice that several top-level directories are symlinks:

``` bash title="Symlinks to /usr"
ls -la / | grep "\->"
# lrwxrwxrwx.  1 root root  7 bin -> usr/bin
# lrwxrwxrwx.  1 root root  7 lib -> usr/lib
# lrwxrwxrwx.  1 root root  9 lib64 -> usr/lib64
# lrwxrwxrwx.  1 root root  8 sbin -> usr/sbin
```

`/bin`, `/sbin`, `/lib`, and `/lib64` are now symlinks pointing into `/usr/`. This is called **UsrMerge** — a consolidation that simplifies package management and makes systems easier to snapshot and maintain.

**What this means practically:** `/bin/bash` and `/usr/bin/bash` point to the same file. You'll see both paths in documentation — they're interchangeable on modern systems.

---

## "Where Do I Find...?" Scenarios

=== "Configuration Files"

    **The answer is almost always /etc.**

    ``` bash title="Finding Configuration"
    # Service configuration
    ls /etc/nginx/              # (1)!
    ls /etc/ssh/                # (2)!
    ls /etc/systemd/system/     # (3)!

    # System-wide configuration
    cat /etc/hosts              # (4)!
    cat /etc/fstab              # (5)!
    cat /etc/environment        # (6)!
    cat /etc/profile            # (7)!

    # Find a config file when you don't know the name
    find /etc -name "*.conf" -type f | grep nginx
    ```

    1. nginx.
    2. SSH server.
    3. systemd unit overrides.
    4. hostname resolution.
    5. disk mounts.
    6. system-wide environment variables.
    7. login shell profile (all users).

    **Pattern:** Start with `ls /etc/` and look for a directory named after the service you're investigating.

=== "Log Files"

    **Always check /var/log first.**

    ``` bash title="Finding Logs"
    ls /var/log/                # (1)!
    ls /var/log/nginx/          # (2)!
    ls /var/log/postgresql/     # (3)!

    # Most important logs
    tail -f /var/log/messages       # (4)!
    tail -f /var/log/syslog         # (5)!
    journalctl -f                   # (6)!
    journalctl -u nginx.service     # (7)!
    ```

    1. everything logs.
    2. nginx access and error logs.
    3. PostgreSQL logs.
    4. general system messages (RHEL/CentOS).
    5. general system messages (Debian/Ubuntu).
    6. systemd journal (all modern systems).
    7. logs for a specific service.

    **Pattern:** If you know the service name, look in `/var/log/<servicename>/`. If nothing's there, use `journalctl -u <servicename>`.

=== "Executables and Binaries"

    **Depends on how it was installed.**

    ``` bash title="Finding Executables"
    # Find where a binary lives
    which nginx         # /usr/sbin/nginx
    which python3       # /usr/bin/python3

    # Show all locations on PATH (catches duplicates)
    type -a python3
    # python3 is /usr/bin/python3
    # python3 is /usr/local/bin/python3

    # Find by name if 'which' doesn't find it
    find /usr /opt -name "myapp" -type f 2>/dev/null
    ```

    | Installed via | Binary lives in |
    |--------------|-----------------|
    | Package manager (`dnf`, `apt`) | `/usr/bin/` or `/usr/sbin/` |
    | Manual compilation / `make install` | `/usr/local/bin/` |
    | Third-party installer | `/opt/<appname>/bin/` |
    | Your own scripts | `/usr/local/bin/` (recommended) |

=== "Application Data and State"

    **Check /var/lib, /opt, or /srv depending on the app.**

    ``` bash title="Finding Application Data"
    # Package-managed services store state here
    ls /var/lib/postgresql/     # (1)!
    ls /var/lib/docker/         # (2)!
    ls /var/lib/rpm/            # (3)!

    # Vendor/self-installed applications
    ls /opt/myapp/              # (4)!

    # Check the service's config for where it stores data
    grep -i "data.dir\|datadir\|data_directory" /etc/postgresql/*/main/postgresql.conf
    ```

    1. PostgreSQL data directory.
    2. Docker container storage.
    3. RPM package database.
    4. self-contained third-party app.

    **Pattern:** For package-manager-installed services, start with `/var/lib/<servicename>/`. For everything else, check `/opt/` and look at the service's config in `/etc/` to find the data directory setting.

---

## Quick Reference

| Directory | Purpose | Persistent? | When to Look Here |
|-----------|---------|-------------|-------------------|
| `/etc` | System configuration | ✅ Yes | Misconfiguration, changing service behavior |
| `/var/log` | Log files | ✅ Yes | Troubleshooting, auditing |
| `/var/lib` | Application state | ✅ Yes | Database files, package databases |
| `/var/cache` | Cached data | ✅ Yes | Package cache, disk space issues |
| `/usr/bin` | User executables | ✅ Yes | Finding binaries installed by packages |
| `/usr/local/bin` | Local executables | ✅ Yes | Custom scripts, manually installed tools |
| `/opt` | Third-party software | ✅ Yes | Vendor apps, self-contained tools |
| `/home` | User home dirs | ✅ Yes | User files, SSH keys, shell config |
| `/boot` | Kernel and boot loader | ✅ Yes | Boot issues, kernel updates |
| `/tmp` | Temporary files | ❌ Cleared on reboot | Scratch space, never put important data here |
| `/proc` | Kernel process info | ❌ Virtual | Live process inspection, kernel tuning |
| `/sys` | Kernel device info | ❌ Virtual | Hardware introspection, driver tuning |
| `/run` | Runtime data | ❌ Cleared on reboot | PID files, sockets, lock files |

---

## Practice Exercises

??? question "Exercise 1: Build the Mental Map"
    Without using any commands, answer these questions from memory:

    1. Where would nginx's configuration file be?
    2. Where would nginx's access logs be?
    3. Where would the nginx binary itself be?
    4. Where would nginx store its runtime PID file?

    Then verify your answers using `find` and `ls`.

    ??? tip "Solution"
        ``` bash title="Verifying Your Mental Map"
        # Configuration
        ls /etc/nginx/
        # nginx.conf  conf.d/  sites-available/  ...

        # Logs
        ls /var/log/nginx/
        # access.log  error.log

        # Binary
        which nginx
        # /usr/sbin/nginx

        # Runtime PID file
        ls /run/nginx.pid
        # or: find /run -name "nginx*"
        ```

??? question "Exercise 2: Trace an Unknown Service"
    A service called `myapp` is running on the server. Using only the filesystem hierarchy knowledge from this article, find:

    1. Its configuration
    2. Its logs
    3. Its binary or startup script
    4. Where it stores data

    **Hint:** Start broad and narrow down.

    ??? tip "Solution"
        ``` bash title="Discovering an Unknown Service"
        # Configuration — start with /etc
        ls /etc/ | grep -i myapp
        find /etc -name "*myapp*" 2>/dev/null

        # Logs — check /var/log and systemd journal
        ls /var/log/ | grep -i myapp
        journalctl -u myapp --no-pager | tail -20

        # Binary — check common locations
        which myapp 2>/dev/null
        find /usr /opt -name "myapp" -type f 2>/dev/null

        # Data — check /var/lib and /opt
        ls /var/lib/ | grep -i myapp
        ls /opt/ | grep -i myapp
        ```

        **Pattern:** When tracing an unknown service, go `/etc` → `/var/log` → `which` → `/var/lib` and `/opt`. Systemd can also tell you: `systemctl cat myapp.service` shows the unit file, which often reveals paths to config, data, and the binary directly.

??? question "Exercise 3: Disk Space Investigation"
    The server's disk is 85% full and growing. Using only filesystem knowledge from this article, identify where to look for the cause.

    ??? tip "Solution"
        ``` bash title="Disk Space Investigation"
        # Start: which filesystem is almost full?
        df -h

        # If it's the root filesystem (/), drill down
        du -sh /var/log/*  | sort -hr | head -10  # (1)!
        du -sh /var/lib/*  | sort -hr | head -10
        du -sh /opt/*      | sort -hr | head -10

        # If /var is a separate mount, check inside it
        du -sh /var/*      | sort -hr | head -10
        ```

        1. `du -sh` gives a human-readable summary per directory. `sort -hr` sorts in human-readable descending order (largest first). `head -10` limits to the top 10.

        **Most common culprits (in order):**

        1. `/var/log/` — unchecked logs from a verbose application
        2. `/var/lib/docker/` — container images and layers accumulating
        3. `/var/lib/postgresql/` or other database directories growing
        4. `/opt/` — an application dumping files without cleanup
        5. `/tmp/` — rarely, but possible if it's on the root filesystem

---

## Quick Recap

The Linux filesystem is organized by purpose, not by application:

- **/etc** — configuration (persistent, edit here to change behavior)
- **/var** — variable data (logs in `/var/log`, state in `/var/lib`)
- **/usr** — installed software (`/usr/bin` for packages, `/usr/local/bin` for custom)
- **/opt** — self-contained third-party applications
- **/proc**, **/sys**, **/run** — virtual filesystems (kernel-generated, ephemeral)
- **/tmp** — temporary files, cleared on reboot

When something isn't working: check `/etc/` for misconfiguration, `/var/log/` for error messages. When you can't find a binary: `which` it or check `/usr/bin/`, `/usr/sbin/`, `/usr/local/bin/`, and `/opt/`. When disk is full: `du -sh /var/*` is your first move.

---

## Further Reading

### Command References

- `man hier` — the filesystem hierarchy manual page (built into every Linux system)
- `man find` — finding files by path, name, size, and modification time
- `man df` — disk space reporting
- `man du` — directory size reporting

### Deep Dives

- [Filesystem Hierarchy Standard 3.0](https://refspecs.linuxfoundation.org/FHS_3.0/fhs/index.html) — the official specification
- [The Linux Documentation Project: Filesystem](https://tldp.org/LDP/Linux-Filesystem-Hierarchy/html/) — detailed explanations of every directory
- [UsrMerge on Fedora Wiki](https://fedoraproject.org/wiki/Features/UsrMove) — background on why `/bin` → `/usr/bin` happened

### Official Documentation

- [Red Hat: Linux Filesystem Hierarchy](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/managing_file_systems/assembly_overview-of-available-file-systems_managing-file-systems) — RHEL filesystem management
- [Debian Policy Manual: Filesystem](https://www.debian.org/doc/debian-policy/ch-opersys.html) — Debian's filesystem conventions
- [The Linux Documentation Project](https://tldp.org/) — HOWTOs and guides

---

## What's Next?

You know where things live. Now you need to find specific things efficiently — when you know *what* you're looking for but not the exact path.

Head to **[Finding Files](finding_files.md)** to learn `find`, `locate`, and `which` — and the practical patterns for locating any file, config, log, or binary on a system you've never touched before.
