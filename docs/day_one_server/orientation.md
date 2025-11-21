# First 60 Seconds: Orientation

You're in. The SSH connection worked, and now you're staring at a blinking cursor on some Linux server. Maybe it looks like this:

```
[jsmith@prod-web-01 ~]$
```

Or maybe it's more cryptic. Either way, you're probably wondering: *Where am I? What is this server? What do I do now?*

**Let's orient ourselves.**

These first 60 seconds are about understanding your environment before you start poking around. Think of it like walking into a new office — you want to know where the exits are before you start moving furniture.

---

## Who Am I?

First question: What user account are you logged in as?

``` bash title="Check Your Username"
whoami
# jsmith
```

Simple. But there's more to know about your identity. The `id` command tells you the full picture:

``` bash title="Full User Identity"
id
# uid=1001(jsmith) gid=1001(jsmith) groups=1001(jsmith),27(sudo),100(users)
```

**What this tells you:**

- `uid=1001(jsmith)` — Your user ID and username
- `gid=1001(jsmith)` — Your primary group
- `groups=...` — All groups you belong to

!!! tip "Spot the sudo"
    If you see `sudo` or `wheel` in your groups, you can run commands as root using `sudo`. That's significant — it means you have elevated privileges.

---

## Where Am I?

When you log in, you start in your home directory. But let's verify:

``` bash title="Print Working Directory"
pwd
# /home/jsmith
```

The `~` symbol is shorthand for your home directory. You'll see it in prompts like `[jsmith@server ~]$`.

**Where is home?**

- Regular users: `/home/username`
- Root user: `/root`
- Service accounts: Varies (sometimes `/var/lib/servicename`)

---

## What Is This Server?

Now let's figure out what machine you're actually on.

### Hostname

``` bash title="Check Hostname"
hostname
# prod-web-01
```

Hostnames often give clues about the server's purpose:
- `prod-web-01` — Production web server
- `staging-db` — Staging database server
- `dev-app-02` — Development application server

### Operating System

What Linux distribution is running here?

``` bash title="Check OS Version"
cat /etc/os-release
```

You'll see something like:

```
NAME="Red Hat Enterprise Linux"
VERSION="8.6 (Ootpa)"
ID="rhel"
...
```

Or for Ubuntu:

```
NAME="Ubuntu"
VERSION="22.04.1 LTS (Jammy Jellyfish)"
ID=ubuntu
...
```

**Quick one-liner for the essentials:**

``` bash title="OS Name and Version"
cat /etc/os-release | grep -E "^NAME=|^VERSION="
```

### Kernel Version

The kernel is the heart of Linux. Check which version you're running:

``` bash title="Check Kernel Version"
uname -r
# 5.14.0-284.11.1.el9_2.x86_64
```

For more system details:

``` bash title="Full System Info"
uname -a
# Linux prod-web-01 5.14.0-284.11.1.el9_2.x86_64 #1 SMP PREEMPT_DYNAMIC ...
```

---

## How Long Has This Server Been Running?

``` bash title="Check Uptime"
uptime
# 14:23:01 up 47 days, 3:12, 2 users, load average: 0.15, 0.10, 0.08
```

**What this tells you:**

- `14:23:01` — Current server time
- `up 47 days, 3:12` — Server has been running for 47 days
- `2 users` — Two users currently logged in
- `load average: 0.15, 0.10, 0.08` — CPU load (1, 5, 15 minute averages)

!!! info "About Load Average"
    Load average shows how busy the CPU is. As a rough guide:

    - **Below 1.0** (per CPU core): Server is relaxed
    - **1.0-2.0** (per CPU core): Normal load
    - **Above 2.0** (per CPU core): Getting busy

    A server with 4 cores can comfortably handle a load of 4.0.

---

## What Resources Does This Server Have?

Before you start working, it's good to know what you're working with.

### CPU Information

``` bash title="Check CPU Info"
lscpu | grep -E "^CPU\(s\)|^Model name"
# CPU(s):                  4
# Model name:              Intel(R) Xeon(R) CPU E5-2686 v4 @ 2.30GHz
```

Or the quick version:

``` bash title="CPU Core Count"
nproc
# 4
```

### Memory (RAM)

``` bash title="Check Memory"
free -h
```

```
              total        used        free      shared  buff/cache   available
Mem:           15Gi       4.2Gi       8.1Gi       312Mi       3.1Gi        10Gi
Swap:         2.0Gi          0B       2.0Gi
```

**Key numbers:**

- `total` — Total RAM installed
- `available` — How much is actually available for new processes (this is what matters!)
- `Swap` — Disk space used as "emergency" memory

!!! warning "Low Available Memory"
    If `available` is very low (less than 10% of total), the server might be struggling. Proceed carefully.

### Disk Space

``` bash title="Check Disk Space"
df -h
```

```
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1       100G   45G   55G  45% /
/dev/sdb1       500G  320G  180G  64% /data
```

**What to look for:**

- `Use%` above 90% is concerning — disk is getting full
- 100% means trouble — things will start failing

Quick version to see just the important filesystems:

``` bash title="Disk Space Summary"
df -h | grep -vE "tmpfs|devtmpfs"
```

---

## Who Else Is Here?

Are other people logged into this server right now?

``` bash title="Who's Logged In"
who
# jsmith   pts/0        2024-01-15 14:20 (192.168.1.50)
# admin    pts/1        2024-01-15 09:45 (192.168.1.25)
```

Or for more detail:

``` bash title="Detailed User List"
w
```

```
 14:25:01 up 47 days,  3:14,  2 users,  load average: 0.12, 0.10, 0.08
USER     TTY      FROM             LOGIN@   IDLE   WHAT
jsmith   pts/0    192.168.1.50     14:20    0.00s  w
admin    pts/1    192.168.1.25     09:45    4:30m  -bash
```

This shows you're not alone — and if someone else is actively working on the server, it's polite to coordinate before making changes.

---

## Quick System Health Check

Want a snapshot of what's happening right now? Here's a one-liner that gives you the essentials:

``` bash title="Quick Health Check"
echo "=== Hostname ===" && hostname && echo "=== Uptime ===" && uptime && echo "=== Memory ===" && free -h | head -2 && echo "=== Disk ===" && df -h / | tail -1
```

Or just use `top` for a live dashboard (press `q` to exit):

``` bash title="Live System Monitor"
top
```

---

## The Orientation Checklist

Here's your first-60-seconds checklist:

| Question | Command | What You Learn |
|----------|---------|----------------|
| Who am I? | `whoami` | Your username |
| What can I do? | `id` | Your groups and permissions |
| Where am I? | `pwd` | Current directory |
| What server is this? | `hostname` | Server name |
| What OS? | `cat /etc/os-release` | Distribution and version |
| How long running? | `uptime` | Uptime and load |
| How much memory? | `free -h` | RAM usage |
| How much disk? | `df -h` | Disk usage |
| Who else is here? | `w` | Other logged-in users |

---

## What NOT to Do Yet

You've oriented yourself. You know what server you're on, what resources it has, and who else is around.

**Resist the urge to:**

- Start editing config files
- Restart any services
- Delete anything
- Run scripts you don't understand

You're still in reconnaissance mode. Keep exploring safely — there's a whole article on that coming up.

---

## Quick Recap

Your first 60 seconds should answer:

1. **Who am I?** → `whoami`, `id`
2. **Where am I?** → `pwd`, `hostname`
3. **What is this?** → `cat /etc/os-release`, `uname -a`
4. **What resources?** → `free -h`, `df -h`, `nproc`
5. **How's it doing?** → `uptime`, `top`
6. **Who else is here?** → `w`

---

## What's Next?

Now that you know where you are and what you're working with, let's talk about what you can actually do here. Head to [Understanding Your Permissions](permissions.md) to learn about sudo, groups, and what level of access you actually have.

!!! tip "Make It a Habit"
    Run these orientation commands every time you log into a new server. It takes 30 seconds and prevents a lot of confusion later.
