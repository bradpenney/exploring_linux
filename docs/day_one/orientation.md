---
date: "2025-11-21 16:34"
title: First 60 Seconds - Linux Server Orientation
description: Just logged in? Learn what the prompt tells you, how to identify the server you're on, and which safe read-only commands reveal everything you need to know.
---

# First 60 Seconds: Orientation

!!! tip "Part of Day One"
    This is the second article in the [Day One: Getting Started](overview.md) series. If you just got Linux access, start with [Getting Access](getting_access.md) first.

You're in. The SSH connection worked, and now you're staring at a blinking cursor on some Linux server. Maybe it looks like this:

```
[jsmith@prod-web-01 ~]$
```

Or maybe it's more cryptic. Either way, you're probably wondering: *Where am I? What is this server? What do I do now?*

**Let's orient ourselves.**

These first 60 seconds are about understanding your environment before you start poking around. Think of it like walking into a new office — you want to know where the exits are before you start moving furniture.

---

## The Orientation Workflow

Here's your path from login to confident exploration:

``` mermaid
graph TD
    A[🔐 Login] --> B[👤 Check Identity]
    B --> C[🖥️ Check Server Info]
    C --> D[💾 Check Resources]
    D --> E[👥 Check Other Users]
    E --> F[✅ Ready to Explore]

    style A fill:#1a202c,stroke:#cbd5e0,stroke-width:2px,color:#fff
    style B fill:#2d3748,stroke:#cbd5e0,stroke-width:2px,color:#fff
    style C fill:#2d3748,stroke:#cbd5e0,stroke-width:2px,color:#fff
    style D fill:#2d3748,stroke:#cbd5e0,stroke-width:2px,color:#fff
    style E fill:#2d3748,stroke:#cbd5e0,stroke-width:2px,color:#fff
    style F fill:#d69e2e,stroke:#cbd5e0,stroke-width:2px,color:#000
```

Each step answers a critical question. Let's explore what you need to check.

---

## What You Need to Check

<div class="grid cards" markdown>

-   :material-account: **Your Identity**

    ---

    **Why it matters:** You need to know your privilege level before exploring. Do you have `sudo` access?

    ``` bash title="Check Who You Are" linenums="1"
    whoami
    # jsmith

    id
    # uid=1001(jsmith) gid=1001(jsmith) groups=1001(jsmith),27(sudo)
    ```

    **Key insight:** If you see `sudo` or `wheel` in your groups, you have elevated privileges. That's significant power—use it carefully.

-   :material-server: **Server Identity**

    ---

    **Why it matters:** Know what server you're on before making any changes. Production? Staging? Dev?

    ``` bash title="What Server Is This?" linenums="1"
    hostname
    # prod-web-01

    cat /etc/os-release | grep -E "^NAME=|^VERSION="  # (1)!
    # NAME="Red Hat Enterprise Linux"
    # VERSION="8.6 (Ootpa)"
    ```

    1. `-E` enables extended regex. `^NAME=` matches lines that start with `NAME=` (the `^` anchors to the line start), and `|` is OR. Without `^`, you'd also match `PRETTY_NAME=` and `VERSION_ID=`, cluttering the output.

    **Key insight:** Hostnames reveal purpose: `prod-web-01` = production, `staging-db` = staging database. Know before you act.

-   :material-memory: **Resource Check**

    ---

    **Why it matters:** Don't run heavy operations on a struggling server. Check capacity before acting.

    ``` bash title="System Health Snapshot" linenums="1"
    free -h
    # Available: 10Gi (check this number!)

    df -h /
    # Use%: 45% (under 90% is good)

    uptime
    # load average: 0.15, 0.10, 0.08 (compare to CPU count)
    ```

    **Key insight:** Low available memory (<10%) or high disk usage (>90%) means proceed carefully. High load (>2× CPU cores) means the server is busy.

-   :material-account-multiple: **Who Else Is Here?**

    ---

    **Why it matters:** If someone else is actively working, coordinate before making changes.

    ``` bash title="Check Other Users" linenums="1"
    w   # (1)!
    ```

    1. Shows who's logged in and what they're doing.

    **Key insight:** See someone with `IDLE` time of 0-5 minutes? They're actively working. Coordinate changes with them.

</div>

---

## Common Scenarios

Different situations call for different orientation checks. Pick your scenario:

=== "Just Logged In - First 30 Seconds"

    **Goal:** Get your bearings immediately after connecting.

    You just need to know: Who am I, where am I, what server is this, and is it healthy?

    ``` bash title="Quick Orientation (30 seconds)" linenums="1"
    whoami              # (1)!
    # jsmith

    pwd                 # (2)!
    # /home/jsmith

    hostname            # (3)!
    # prod-web-01

    uptime              # (4)!
    # 14:23:01 up 47 days, 3:12, 2 users, load average: 0.15, 0.10, 0.08
    ```

    1. Your username.
    2. Where am I in the filesystem?
    3. Server name.
    4. Is it healthy?

    **What you learned:**

    - You're logged in as `jsmith`
    - You're in your home directory (`/home/jsmith`)
    - This is the `prod-web-01` server
    - It's been running 47 days with low load (healthy)

    !!! tip "Understanding Your Location"
        When you log in, you start in your **home directory**:

        - Regular users: `/home/username`
        - Root user: `/root`
        - Service accounts: Varies (often `/var/lib/servicename`)

        The `~` symbol is shorthand for your home directory. You'll see it in prompts like `[jsmith@server ~]$`.

    **Next step:** If load looks good and it's the right server, you're safe to explore.

=== "Before Making Changes"

    **Goal:** Safety check before modifying files, restarting services, or running commands.

    Before you change anything, verify three things: correct server, no high load, no active users.

    ``` bash title="Pre-Change Safety Check" linenums="1"
    hostname            # (1)!
    # prod-web-01       ✓ Correct server

    w                   # (2)!
    # jsmith   pts/0    14:20    0.00s  -bash
    # admin    pts/1    09:45   4:30m   -bash    ← Someone idle (safe)

    uptime              # (3)!
    # load average: 0.15, 0.10, 0.08    ← Low load (safe to proceed)
    ```

    1. Confirm correct server.
    2. Who else is here?
    3. Is it busy?

    **Decision time:**

    - ✅ **Proceed:** Load is low, other users are idle, correct server
    - ⚠️ **Wait:** Load is high (>2× CPU cores)—find out why first
    - ⚠️ **Coordinate:** Other user has low idle time—ask before changing things

=== "Manager Asked About Resources"

    **Goal:** Report on server capacity and utilization.

    Your manager or team lead wants to know if the server has capacity for new workloads.

    ``` bash title="Resource Report Commands" linenums="1"
    # CPU capacity
    nproc
    # 4                  ← 4 CPU cores available

    # Memory status
    free -h
    #               total        used        free      available
    # Mem:           15Gi       4.2Gi       8.1Gi        10Gi    ← 10Gi available for new work

    # Disk space
    df -h | grep -vE "tmpfs|devtmpfs"  # (1)!
    # /dev/sda1       100G   45G   55G  45% /              ← 55GB free (55%)
    # /dev/sdb1       500G  320G  180G  64% /data          ← 180GB free (36%)

    # Current load
    uptime
    # load average: 0.15, 0.10, 0.08    ← Very light load (0.15 on 4 cores = 3.75% utilization)

    # OS and kernel version
    cat /etc/os-release | grep -E "^NAME=|^VERSION="
    # NAME="Red Hat Enterprise Linux"
    # VERSION="8.6 (Ootpa)"

    uname -r
    # 5.14.0-284.11.1.el9_2.x86_64      ← Kernel version
    ```

    1. `-v` inverts the match — shows lines that do NOT match. `-E` enables extended regex for the `|` OR operator. Together: skip `tmpfs` and `devtmpfs`, which are virtual memory filesystems, not real disks.

    **What to report:**

    - **CPU:** 4 cores, currently at ~4% utilization (load 0.15)
    - **Memory:** 15GB total, 10GB available for new processes
    - **Disk:** Root filesystem 55% free (55GB), data volume 36% free (180GB)
    - **OS:** Red Hat Enterprise Linux 8.6, kernel 5.14.0
    - **Assessment:** Server has significant capacity for additional workloads

=== "Something Seems Wrong"

    **Goal:** Diagnose why the server feels slow or unresponsive.

    The server is sluggish or commands are taking forever. Check what's happening.

    ``` bash title="Health Diagnostics" linenums="1"
    # Check system load
    uptime
    # load average: 8.45, 7.23, 6.12    ← High load! (on 4 cores = 2× capacity)

    # Check memory pressure
    free -h
    #               total        used        free      available
    # Mem:           15Gi        14Gi       512Mi       800Mi    ← Low available memory!

    # Check disk space
    df -h /
    # /dev/sda1       100G   98G   2.0G  98% /          ← Disk almost full!

    # See what's running
    top
    # Press 'q' to exit when done
    ```

    **Red flags:**

    - ⚠️ **High load (>2× CPU cores):** Something is consuming CPU heavily
    - ⚠️ **Low available memory (<10%):** System is memory-constrained
    - 🚨 **Disk >90% full:** Critical—things will start failing soon

    **What to do:**

    - Don't make changes yet—you could make it worse
    - If load is the issue, `top` (already in the commands above) sorts processes by CPU at the top of the list — the culprit is usually the first entry. `htop` is a friendlier alternative if installed
    - Document what you found (screenshot or copy the output)
    - Escalate to your team: "Server XYZ has [high load / low memory / full disk], top process is [name]"
    - Let experienced team members decide whether to intervene

---

## Quick Reference Checklist

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

You're still in reconnaissance mode. Keep exploring safely — head to **[Safe Exploration](safe_exploration.md)** to learn how to look around without breaking things.

---

## Practice Problems

??? question "Problem 1: Server Reconnaissance"
    Log into a server and gather the following information:

    - Username and groups
    - Hostname
    - OS distribution and version
    - Available memory
    - Disk space usage

    **Goal:** Complete this in under 60 seconds.

    ??? tip "Answer"
        ``` bash title="Quick Orientation Commands" linenums="1"
        whoami
        id
        hostname
        cat /etc/os-release | grep -E "^NAME=|^VERSION="
        free -h
        df -h
        ```

        **Tip:** Create a shell alias or script to run these commands automatically on login.

??? question "Problem 2: Interpret Load Average"
    A server shows: `load average: 8.45, 7.23, 6.12`

    It has 4 CPU cores. Is this server:

    - Relaxed
    - Normal load
    - Getting busy
    - Critical?

    **Hint:** Compare the load to the number of cores.

    ??? tip "Answer"
        **Getting busy / Critical**

        With 4 cores, a comfortable load is around 4.0. At 8.45, the server is handling twice its comfortable capacity. You should investigate what's consuming resources using `top` or `htop`.

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

## Further Reading

### Command References

- `man whoami` - User identity commands
- `man uptime` - System uptime and load
- `man free` - Memory usage reporting
- `man df` - Disk space reporting
- `man w` - Show who is logged in and what they're doing
- `man uname` - Print system information

### Deep Dives

- [Understanding Linux Load Averages](https://www.brendangregg.com/blog/2017-08-08/linux-load-averages.html) - Comprehensive explanation of load metrics
- [Brendan Gregg's Linux Performance](https://www.brendangregg.com/linuxperf.html) - Performance analysis tools and methodology

### Official Documentation

- [Red Hat Enterprise Linux Documentation](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/) - RHEL system administration guides
- [Ubuntu Server Documentation](https://ubuntu.com/server/docs) - Ubuntu-specific server guides
- [Debian Administrator's Handbook](https://debian-handbook.info/) - Comprehensive Debian/Ubuntu reference
- [The Linux Documentation Project](https://tldp.org/) - Guides, HOWTOs, and FAQs
- [Linux Kernel Documentation](https://www.kernel.org/doc/html/latest/) - Official kernel documentation

---

## What's Next?

Now that you know where you are and what you're working with, it's time to understand what you're actually allowed to do on this server. Head to **[Understanding Your Permissions](permissions.md)** to learn about your access level and how to use `sudo` safely.

Once you've worked through **[Safe Exploration](safe_exploration.md)**, continue to **[Reading Logs Like a Pro](reading_logs.md)** to learn how to diagnose problems on production systems.

!!! tip "Make It a Habit"
    Run these orientation commands every time you log into a new server. It takes 30 seconds and prevents a lot of confusion later.
