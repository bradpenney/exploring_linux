# The Linux Filesystem Hierarchy: A Guided Tour

!!! quote "Everything has its place, and there's a place for everything"

## The Organized Filing Cabinet

Imagine walking into a library where books are shelved randomly. It would be impossible to find anything. The power of a library is its organization—fiction here, non-fiction there, biographies on that wall.

The Linux filesystem is like that well-organized library. It might seem like a chaotic collection of cryptic three-letter directories at first, but there's a deep, logical structure to it, defined by the **Filesystem Hierarchy Standard (FHS)**.

Understanding this "map" is a superpower. It transforms you from a tourist into a local. You'll know where to find configuration files, where applications are installed, where logs are stored, and where your own files belong.

Let's take a tour of the main "sections" of this library.

## The Root of Everything: `/`

Everything in Linux starts from a single point: the **root directory**, represented by a single forward slash (`/`). Every other file and directory is "under" this root.

```bash
cd /
pwd
# /
ls
# bin  boot  dev  etc  home  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
```

## The Most Important Directories

While there are many directories, you'll spend 95% of your time interacting with these.

| Directory | Purpose | Analogy |
|:---|:---|:---|
| `/home` | **Your Personal Space** | Your desk or office. |
| `/etc` | **System Configuration** | The building's control room. |
| `/var` | **Variable Data** | The library's newspaper archive. |
| `/tmp` | **Temporary Files** | A scratchpad or whiteboard. |
| `/usr` | **User Programs** | The main library stacks. |
| `/bin`, `/sbin` | **Essential Binaries** | The emergency toolkit. |

---

### `/home`: Your Personal Space

This is where user accounts live. When you log in, you start in your home directory (`/home/yourusername`).

-   **What's inside:** Your documents, downloads, pictures, and personal configuration files (like `.bashrc`, `.gitconfig`).
-   **Permissions:** You have full read/write/execute permissions here. You can't touch other users' home directories unless they allow it.

```bash
ls /home
# brad  jane  sara
```

### `/etc`: The System's Brain

Pronounced "et-see," this directory holds the configuration files for the entire system and all its services.

-   **What's inside:** `passwd` (user accounts), `fstab` (disk mounts), `sshd_config` (SSH server settings), `nginx/` (web server configs).
-   **Permissions:** Mostly owned by `root`. You'll need `sudo` to edit files here. You'll spend a lot of time *reading* files in `/etc` to understand how a system is configured.

```bash
ls /etc/nginx
# nginx.conf  sites-available/  sites-enabled/
```

### `/var`: The Changing Files

`var` stands for "variable." This is where files that are expected to grow and change in size are kept. The most important subdirectory is `/var/log`.

-   **What's inside:**
    -   `/var/log`: System and application logs (`syslog`, `auth.log`, `nginx/`).
    -   `/var/www`: Web server content (on some systems).
    -   `/var/spool`: Mail, print jobs, and other queued tasks.
-   **Why it matters:** When a disk fills up, it's often because of a file in `/var/log`.

```bash
# Check recent system logs
tail /var/log/syslog
```

### `/tmp`: The Scratchpad

A world-writable directory for temporary files. Any user can write here.

-   **What's inside:** Temporary files created by applications, or your own short-lived scripts and downloads.
-   **Key feature:** Files in `/tmp` are often **deleted on reboot**. Don't store anything important here.

---

## The "Binary" Directories: `/bin`, `/sbin`, `/usr/bin`, `/usr/sbin`

These directories hold executable programs (binaries). The separation can be confusing, but here's a simple breakdown:

-   `/bin` (User Binaries): Essential commands available to **all users** (`ls`, `cp`, `mv`, `cat`).
-   `/sbin` (System Binaries): Essential commands for **system administration**, usually run by `root` (`fdisk`, `iptables`, `reboot`).
-   `/usr/bin`: The main location for user-installable programs (`firefox`, `python`, `htop`). Most programs you install will end up here.
-   `/usr/sbin`: Non-essential system administration commands.

!!! tip "What's in Your `$PATH`?"
    The reason you can type `ls` instead of `/bin/ls` is because `/bin` is in your `$PATH` environment variable. Your shell searches the directories in `$PATH` to find the command you typed.

## The "User" Directory: `/usr`

`/usr` (Unix System Resources) is one of the largest directories. It contains shareable, read-only data. Think of it as the "Program Files" directory of Linux.

-   **`/usr/bin`**: User binaries (as above).
-   **`/usr/sbin`**: System binaries (as above).
-   **`/usr/lib`**: Libraries for the programs in `/usr/bin` and `/usr/sbin`.
-   **`/usr/share`**: Architecture-independent shared data, like documentation (`/usr/share/doc`) and man pages (`/usr/share/man`).

## The "Everything is a File" Directories: `/dev`, `/proc`, `/sys`

These are not "real" directories on your hard drive. They are virtual filesystems created by the kernel at boot time to expose information about the system.

-   `/dev` (Devices): Contains "device files" that represent hardware. Your hard drive (`/dev/sda`), your terminal (`/dev/tty`), even nothingness (`/dev/null`).
-   `/proc` (Processes): Contains information about running processes and kernel parameters. `ps` and `top` get their information from here. Each running process has a directory named after its PID (e.g., `/proc/1234`).
-   `/sys` (System): A newer, more organized way to see information about devices and drivers.

You rarely interact with these directly, but it's good to know they exist and what they represent.

## Other Notable Directories

-   `/root`: The home directory for the `root` user. Not to be confused with `/`.
-   `/boot`: Files needed to boot the system, including the Linux kernel itself.
-   `/opt` (Optional): For third-party software that doesn't follow the standard hierarchy (e.g., Google Chrome, Slack).
-   `/mnt` (Mount): A temporary mount point for mounting filesystems.
-   `/media`: Where removable media (USB drives, CDs) are automatically mounted.

## Why Does This Hierarchy Matter?

-   **Predictability:** You know where to look for things on *any* Linux system. Logs are in `/var/log`. Configs are in `/etc`.
-   **Troubleshooting:** "Disk is full?" Check `/var` and `/home`. "App won't start?" Check its config in `/etc` and logs in `/var/log`.
-   **Security:** Core system files (`/bin`, `/etc`) are owned by `root`, protecting them from normal users.
-   **Understanding:** It provides a mental model of how the operating system is put together.

## Practice Exercises

**Exercise 1: Explore `/etc`**
What's inside your `/etc` directory? Find a configuration file for a program you recognize.
```bash
cd /etc
ls
cat hosts  # A simple, safe config file to view
```

**Exercise 2: Find Your Shell**
Where does the `bash` executable live?
```bash
which bash
# The output will likely be /bin/bash or /usr/bin/bash
```

**Exercise 3: Check a Log File**
List the contents of `/var/log`. Is there a file named `syslog` or `messages`? View the last 10 lines.
```bash
ls /var/log
tail /var/log/syslog # or /var/log/messages
```

## Key Takeaways

| Directory | What it's for |
|:---|:---|
| `/` | The root of everything. |
| `/home` | User's personal files. |
| `/etc` | System-wide configuration files. |
| `/var/log` | System and application log files. |
| `/tmp` | Temporary files (deleted on reboot). |
| `/bin`, `/usr/bin` | Executable programs. |
| `/sbin`, `/usr/sbin` | System administration executables. |
| `/dev`, `/proc`, `/sys`| Virtual directories representing the system state. |

Navigating the Linux filesystem hierarchy is like learning the layout of a city. At first, you need a map for everything. With practice, you'll know exactly where to go without even thinking about it.
