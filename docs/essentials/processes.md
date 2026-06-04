---
title: Processes in Linux - Managing Running Programs
description: Understand Linux process management — ps, top, kill, signals, process states, and the tools every sysadmin uses to investigate and control a running system.
---

# Processes

!!! tip "Part of Essentials"
    This article covers interactive process management. For managing services that start at boot and persist across reboots, see the Services with systemd article in the Efficiency track (coming soon).

Something is consuming all the CPU. An application is hung and won't respond. A background job you kicked off is still running and you need to stop it. The server is sluggish and you need to find the culprit in 30 seconds.

Every one of these situations requires the same starting point: understanding what's running, what resources it's using, and how to control it. Processes are the living instance of a program — and managing them is one of the most frequent tasks in Linux administration.

---

## Where You've Seen This

If you've used Windows, the mapping is direct:

| Windows | Linux Equivalent |
|---------|-----------------|
| Task Manager (Processes tab) | `top` or `htop` |
| Task Manager (Details tab) | `ps aux` |
| Services (services.msc) | Processes + systemd (covered in Efficiency) |
| `tasklist` | `ps aux` |
| `taskkill /PID 1234` | `kill 1234` |
| `taskkill /F /PID 1234` | `kill -9 1234` |
| End Task | `kill PID` (SIGTERM) |
| End Process Tree | `kill -9 PID` (SIGKILL) |

The key difference: Linux gives you far more control. Signals let you tell a process to reload its config without restarting (`kill -HUP`), pause it (`kill -STOP`), or resume it (`kill -CONT`). Windows' "End Task" is a blunt instrument by comparison.

The other difference: on Linux, understanding processes means understanding the process tree. Every process has a parent. When you know PID 1 is `systemd` and all services descend from it, process management starts to make intuitive sense.

---

## What Is a Process?

When you run a command, Linux creates a **process** — an isolated instance of that program with its own memory space, file descriptors, and execution state. Every process has:

- A **PID** (Process ID): unique numeric identifier
- A **PPID** (Parent Process ID): the process that created it
- An **owner**: the user whose permissions it runs with
- A **state**: running, sleeping, stopped, or zombie

``` mermaid
graph TD
    INIT["🔵 systemd (PID 1)\nThe init process — parent of all others"]
    SSHD["sshd (PID 892)\nSSH daemon"]
    BASH["bash (PID 1234)\nYour login shell"]
    CMD["ls (PID 1235)\nCommand you ran"]
    NGINX["nginx master (PID 445)\nWeb server"]
    WORKER["nginx worker (PID 446)\nHandles requests"]

    INIT --> SSHD
    INIT --> NGINX
    SSHD --> BASH
    BASH --> CMD
    NGINX --> WORKER

    style INIT fill:#d69e2e,stroke:#cbd5e0,stroke-width:2px,color:#000
    style SSHD fill:#2d3748,stroke:#63b3ed,stroke-width:2px,color:#fff
    style BASH fill:#2d3748,stroke:#63b3ed,stroke-width:2px,color:#fff
    style CMD fill:#2d3748,stroke:#68d391,stroke-width:2px,color:#fff
    style NGINX fill:#2d3748,stroke:#fc8181,stroke-width:2px,color:#fff
    style WORKER fill:#2d3748,stroke:#fc8181,stroke-width:2px,color:#fff
```

Every process on the system descends from PID 1 — `systemd` (or `init` on older systems). When a parent process exits, its children are re-parented to PID 1.

---

## Viewing Processes: ps

`ps` (process status) is the primary tool for inspecting running processes.

### The Essential ps Invocations

``` bash title="Common ps Usage"
# The classic: every process, full details
ps aux

# Every process in a tree view (shows parent/child relationships)
ps auxf

# Processes owned by a specific user
ps -u www-data

# Processes for the current terminal only
ps

# Specific process by name
ps aux | grep nginx
pgrep -la nginx    # cleaner alternative
```

### Reading ps aux Output

``` bash title="ps aux Output Explained"
ps aux
# USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
# root         1  0.0  0.1 168940 11232 ?        Ss   Mar09   0:05 /sbin/init
# nginx      445  0.0  0.2 108876 18440 ?        Ss   10:00   0:00 nginx: master
# nginx      446  0.1  0.4 109264 33280 ?        S    10:00   2:14 nginx: worker
# jsmith    1234  0.0  0.1  24256  8420 pts/0    Ss   14:23   0:00 -bash
```

| Column | Meaning |
|--------|---------|
| `USER` | Process owner |
| `PID` | Process ID |
| `%CPU` | CPU usage (averaged) |
| `%MEM` | Physical memory percentage |
| `VSZ` | Virtual memory size (KB) |
| `RSS` | Resident set size — actual RAM in use (KB) |
| `STAT` | Process state |
| `START` | When process started |
| `TIME` | Total CPU time consumed |
| `COMMAND` | The command and its arguments |

### Process States

The `STAT` column tells you what the process is doing:

| Code | State | Meaning |
|------|-------|---------|
| `R` | Running | Actively using CPU |
| `S` | Sleeping | Waiting for event (interruptible) |
| `D` | Disk wait | Waiting for I/O (uninterruptible) |
| `T` | Stopped | Paused (Ctrl+Z or SIGSTOP) |
| `Z` | Zombie | Finished but parent hasn't acknowledged yet |
| `s` | Session leader | First process in a session |
| `l` | Multithreaded | Has multiple threads |
| `+` | Foreground | In the foreground process group |
| `<` | High priority | Nice value negative |
| `N` | Low priority | Nice value positive |

**What to watch for:**

- Lots of `D` processes → disk I/O bottleneck
- `Z` (zombie) processes → parent not collecting exit status (usually harmless in small numbers)
- `T` (stopped) → process was paused, possibly accidentally

---

## top and htop: Live Monitoring

`ps` is a snapshot. `top` and `htop` are live views that update continuously.

### top — Always Available

``` bash title="Using top"
top         # launches the live process monitor
top -u jsmith   # filter to one user's processes
top -p 1234     # monitor a specific PID
```

**Inside top:**

``` bash title="top Keyboard Shortcuts"
q       # quit
k       # kill a process (prompts for PID and signal)
r       # renice (change priority)
M       # sort by memory usage
P       # sort by CPU usage (default)
1       # show individual CPU cores
u       # filter by user
f       # manage display fields
```

**Reading the top header:**

``` bash title="top Header Fields"
top - 14:23:15 up 47 days, 3:12,  2 users,  load average: 0.15, 0.10, 0.08
# uptime and load averages (1min, 5min, 15min)

Tasks: 187 total,   1 running, 185 sleeping,   0 stopped,   1 zombie
# process states at a glance

%Cpu(s):  5.2 us,  1.3 sy,  0.0 ni, 92.8 id,  0.7 wa,  0.0 hi,  0.0 si,  0.0 st
# CPU breakdown: user, system, idle, wait (io), etc.

MiB Mem :  15826.1 total,  8234.5 free,  4127.9 used,  3463.7 buff/cache
MiB Swap:   2048.0 total,  2048.0 free,     0.0 used.  10834.6 avail Mem
```

**`wa` (wait)** above 5-10% indicates an I/O bottleneck. **`us` (user)** high means application code is consuming CPU. **`sy` (system)** high means kernel activity — often disk or network.

### htop — If Available

`htop` is a friendlier alternative with color, a tree view, and mouse support. Install it if it's not there (`dnf install htop` / `apt install htop`). Use it exactly like `top` but with arrow keys to navigate and F-keys for actions.

---

## Finding Processes

``` bash title="Finding Specific Processes"
# By name — returns PIDs only
pgrep nginx
# 445
# 446

# By name with command details
pgrep -la nginx
# 445 nginx: master process /usr/sbin/nginx -g daemon off;
# 446 nginx: worker process

# By user
pgrep -u www-data

# By name using ps
ps aux | grep "[n]ginx"    # bracket trick prevents grep from matching itself

# Find PID of process listening on a port
ss -tlnp | grep ":8080"
lsof -i :8080              # if lsof is installed
```

---

## Signals: Communicating With Processes

**Signals** are messages you send to a process to tell it to do something — stop, restart, reload configuration, or terminate.

``` bash title="Sending Signals"
# Send a signal by PID
kill PID              # default: SIGTERM (15) — polite stop
kill -9 PID           # SIGKILL — forceful, cannot be ignored
kill -1 PID           # SIGHUP — reload configuration
kill -STOP PID        # pause the process
kill -CONT PID        # resume a paused process

# Send signal by name
killall nginx         # send SIGTERM to all processes named nginx
pkill -u jsmith       # send SIGTERM to all of jsmith's processes
pkill -9 -u jsmith    # forcefully kill all of jsmith's processes
```

### The Essential Signals

| Signal | Number | Meaning | Can Be Caught? |
|--------|--------|---------|----------------|
| `SIGHUP` | 1 | Hangup — reload config | Yes |
| `SIGINT` | 2 | Interrupt — what Ctrl+C sends | Yes |
| `SIGQUIT` | 3 | Quit with core dump | Yes |
| `SIGKILL` | 9 | Kill immediately | **No — cannot be caught or ignored** |
| `SIGTERM` | 15 | Terminate gracefully | Yes |
| `SIGSTOP` | 19 | Pause execution | **No — cannot be caught** |
| `SIGCONT` | 18 | Resume execution | No |
| `SIGUSR1/2` | 10/12 | User-defined (varies by app) | Yes |

### The SIGTERM vs SIGKILL Decision

!!! warning "Prefer SIGTERM Over SIGKILL"
    `kill -9` is tempting because it always works. But it's also dangerous:

    - The process cannot clean up — open files may be corrupted, database transactions left open, locks not released
    - Child processes are orphaned (reparented to PID 1)
    - Logs may be incomplete

    **Always try SIGTERM first:** `kill PID` — wait 5-10 seconds. If the process doesn't exit, *then* consider `kill -9 PID`.

    Legitimate uses for SIGKILL: a process that's genuinely hung and not responding to SIGTERM after a reasonable wait, or when a process is stuck in `D` state (uninterruptible disk wait).

### SIGHUP for Config Reloads

Many services use SIGHUP to reload their configuration without restarting:

``` bash title="Reload Config Without Restart"
# Find the process PID
pgrep nginx
# 445

# Send SIGHUP to reload config
kill -HUP 445
# or equivalently:
kill -1 445
nginx -s reload   # nginx-specific wrapper for the same thing
```

For services managed by systemd, `systemctl reload servicename` is the preferred approach — it handles the signal and verifies the reload succeeded.

---

## Background Jobs and Job Control

When you run a command, it runs in the foreground by default — your terminal is blocked until it finishes. Job control lets you manage multiple commands in one terminal session.

``` bash title="Job Control"
# Run a command in the background immediately
long-running-command &
# [1] 1234        ← job number and PID

# Pause a running command and put it in background
# (while it's running, press Ctrl+Z)
^Z
# [1]+  Stopped    long-running-command

# Resume in background
bg %1

# Resume in foreground
fg %1

# List current jobs
jobs
# [1]-  Running    long-running-command &
# [2]+  Stopped    another-command

# Kill a job by job number
kill %1
```

### nohup — Survive Logout

By default, background jobs receive SIGHUP when you log out, killing them. `nohup` prevents this:

``` bash title="Using nohup"
nohup ./long-script.sh &
# Sends output to nohup.out by default

nohup ./long-script.sh > /var/log/myscript.log 2>&1 &
# Better: explicit output file

# Check it's still running after logout
pgrep -la long-script
```

For long-running tasks, consider `tmux` or `screen` for persistent terminal sessions — they're more flexible than `nohup`.

---

## Common Scenarios

=== "Server Is Slow: Find the Culprit"

    The server feels sluggish. Find what's consuming resources.

    ``` bash title="Resource Investigation"
    # Quick snapshot: who's consuming CPU?
    ps aux --sort=-%cpu | head -10

    # Who's consuming memory?
    ps aux --sort=-%mem | head -10

    # Live view sorted by CPU
    top   # then press P to sort by CPU

    # Check load average context
    uptime
    # load average: 8.45, 7.23, 6.12  ← high on a 4-core system

    # If load is high but CPU isn't, check disk wait
    top   # look for high 'wa' in CPU line

    # What's doing disk I/O?
    iotop   # if installed
    # or: ps aux | awk '$8=="D"'   ← processes in disk wait
    ```

=== "Kill a Hung Process"

    An application is hung and won't respond to normal shutdown.

    ``` bash title="Kill a Hung Process"
    # Find the PID
    pgrep -la myapp
    # 1234 myapp --config /etc/myapp/config.yml

    # Try graceful termination first
    kill 1234
    # wait 10 seconds...

    # Check if it's gone
    ps -p 1234
    # if still there:

    # Force kill
    kill -9 1234

    # Verify it's gone
    ps -p 1234
    # should show nothing
    ```

=== "Check What a Process Is Doing"

    You see a process consuming resources but don't know what it's doing.

    ``` bash title="Process Investigation"
    # What files does it have open?
    lsof -p 1234

    # What network connections does it have?
    lsof -p 1234 -i

    # What files does it have open (via /proc)
    ls -la /proc/1234/fd/

    # What command started it?
    cat /proc/1234/cmdline | tr '\0' ' '

    # What environment variables does it have?
    cat /proc/1234/environ | tr '\0' '\n'

    # What's its current working directory?
    ls -la /proc/1234/cwd
    ```

=== "Long-Running Job: Run and Detach"

    You need to run a script that takes hours and you need to log out.

    ``` bash title="Long-Running Jobs"
    # Option 1: nohup (simple)
    nohup ./backup-script.sh > /var/log/backup.log 2>&1 &
    echo $!    # print the PID to track it
    disown     # detach from current shell (so logout doesn't signal it)

    # Option 2: tmux (better — you can reattach)
    tmux new-session -s backup
    # run your script inside tmux
    # then Ctrl+B, D to detach
    # later: tmux attach -t backup

    # Check if your background job is still running
    pgrep -la backup-script
    tail -f /var/log/backup.log
    ```

---

## Quick Reference

### Process Inspection

| Command | What It Shows |
|---------|--------------|
| `ps aux` | All processes, full details |
| `ps auxf` | All processes, tree view |
| `ps -u username` | Processes by user |
| `pgrep name` | PIDs for named processes |
| `pgrep -la name` | PIDs and commands for named processes |
| `top` | Live process monitor |
| `top -p PID` | Monitor a specific PID |

### Signals

| Command | Effect |
|---------|--------|
| `kill PID` | Send SIGTERM (graceful stop) |
| `kill -9 PID` | Send SIGKILL (force kill) |
| `kill -HUP PID` | Send SIGHUP (reload config) |
| `kill -STOP PID` | Pause process |
| `kill -CONT PID` | Resume paused process |
| `killall name` | Send SIGTERM to all matching |
| `pkill -9 name` | Force kill all matching |

### Job Control

| Command | Effect |
|---------|--------|
| `command &` | Run in background |
| `Ctrl+Z` | Pause foreground job |
| `bg %1` | Resume job 1 in background |
| `fg %1` | Bring job 1 to foreground |
| `jobs` | List current jobs |
| `kill %1` | Kill job 1 |
| `nohup cmd &` | Run, survive logout |

---

## Practice Exercises

??? question "Exercise 1: Find Resource Consumers"
    Without using `top`, find:

    1. The process consuming the most CPU
    2. The process consuming the most memory
    3. Their PIDs and who owns them

    ??? tip "Solution"
        ``` bash title="Resource Consumer Investigation"
        # Most CPU (--sort uses ps column names)
        ps aux --sort=-%cpu | head -3

        # Most memory
        ps aux --sort=-%mem | head -3

        # Or combined: show PID, user, CPU%, MEM%, command
        ps aux --sort=-%cpu | awk 'NR<=6 {printf "%-10s %-8s %-6s %-6s %s\n", $1, $2, $3, $4, $11}'
        ```

??? question "Exercise 2: Gracefully Stop and Verify"
    Find the nginx master process PID, send it SIGTERM, wait, and verify it stopped.

    ??? tip "Solution"
        ``` bash title="Stop nginx Gracefully"
        # Find the master process PID
        pgrep -la nginx | grep master
        # 445 nginx: master process /usr/sbin/nginx

        # Send SIGTERM
        kill 445

        # Wait a moment, then verify
        sleep 3
        ps -p 445
        # If it shows nothing, the process is gone

        # Or check via pgrep
        pgrep nginx
        # No output = no nginx processes running
        ```

        Note: In production, use `systemctl stop nginx` rather than killing directly — systemd handles the signal, verifies shutdown, and updates the service state.

??? question "Exercise 3: Background Job Management"
    Run `sleep 300` in the background, verify it's running, then pause it, then kill it.

    ??? tip "Solution"
        ``` bash title="Job Control Practice"
        # Start in background
        sleep 300 &
        # [1] 2345

        # Verify it's running
        jobs
        # [1]+  Running    sleep 300 &

        ps -p 2345
        # Shows the sleep process

        # Pause it
        kill -STOP 2345

        # Check state (should show T = stopped)
        ps -p 2345 -o pid,stat,command

        # Kill it
        kill 2345
        # Or kill %1 using job number

        # Verify it's gone
        jobs
        # (empty)
        ```

---

## Quick Recap

- **Every process** has a PID, PPID, owner, and state; all descend from PID 1 (systemd)
- **`ps aux`** — snapshot of all processes; **`ps auxf`** — with parent/child tree
- **`pgrep -la name`** — find PIDs by name; cleaner than `ps aux | grep`
- **`top`** — live view; `M` sorts by memory, `P` by CPU, `1` shows per-core
- **Process states:** `R` running, `S` sleeping, `D` disk wait, `Z` zombie, `T` stopped
- **SIGTERM (15)** — polite stop, process can clean up; **SIGKILL (9)** — force kill, cannot be caught; always try SIGTERM first
- **SIGHUP (1)** — reload configuration; standard for web servers and daemons
- **Job control:** `command &` runs in background, `Ctrl+Z` pauses, `fg`/`bg` to move, `nohup` to survive logout

---

## Further Reading

### Command References

- `man ps` — all ps options including output formatting
- `man top` — complete top reference and interactive commands
- `man kill` — signal list and usage
- `man signal` — the full POSIX signal specification
- `man pgrep` — process search with pattern matching
- `man lsof` — list open files for a process

### Deep Dives

- [Brendan Gregg: Linux Performance](https://www.brendangregg.com/linuxperf.html) — authoritative Linux performance tools including process analysis
- [Linux Process States](https://www.baeldung.com/linux/process-states) — detailed explanation of all process states
- [Understanding /proc filesystem](https://www.kernel.org/doc/html/latest/filesystems/proc.html) — kernel documentation for /proc

### Official Documentation

- [Red Hat: Managing Processes](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/monitoring_and_managing_system_status_and_performance/managing-processes_monitoring-and-managing-system-status-and-performance) — RHEL process management guide
- [Linux Kernel Documentation: /proc](https://www.kernel.org/doc/html/latest/filesystems/proc.html) — the /proc virtual filesystem

---

## What's Next?

You've covered four of the five Essentials categories. The commands from the command line, users and access, text pipelines, and process management are now in your toolkit.

The final Essentials category is **Bash Scripting** — where all of those commands become repeatable automation. Start with [Your First Bash Script](bash_first_script.md).

After completing Essentials, the **Efficiency** track covers the daily-use tools that experienced Linux professionals reach for: systemd for service management, `sed` for text transformation, and package management for keeping systems current.
