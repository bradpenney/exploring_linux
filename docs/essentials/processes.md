---
date: "2026-04-04 18:47"
title: Processes in Linux - Managing Running Programs
description: Understand Linux process management — ps, top, kill, signals, process states, and the tools every sysadmin uses to investigate and control a running system.
---

# Processes

!!! tip "Part of Essentials"
    This article covers interactive process management. Services that start at boot and persist across reboots are a different discipline — systemd's job, and a topic of its own.

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
ps aux                  # (1)!
ps auxf                 # (2)!
ps -u www-data          # (3)!
ps                      # (4)!
ps aux | grep nginx     # (5)!
pgrep -la nginx         # (6)!
```

1. The classic: every process, full details.
2. Tree view — shows parent/child relationships.
3. Processes owned by a specific user.
4. Processes for the current terminal only.
5. Find a specific process by name.
6. Cleaner alternative — lists matching PIDs with their command line, no `grep` needed.

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
top             # (1)!
top -u jsmith   # (2)!
top -p 1234     # (3)!
```

1. Launches the live process monitor.
2. Filter to one user's processes.
3. Monitor a specific PID.

**Inside top:**

``` bash title="top Keyboard Shortcuts"
q       # (1)!
k       # (2)!
r       # (3)!
M       # (4)!
P       # (5)!
1       # (6)!
u       # (7)!
f       # (8)!
```

1. Quit.
2. Kill a process (prompts for PID and signal).
3. Renice (change priority).
4. Sort by memory usage.
5. Sort by CPU usage (default).
6. Show individual CPU cores.
7. Filter by user.
8. Manage display fields.

**Reading the top header:**

``` bash title="top Header Fields"
top - 14:23:15 up 47 days, 3:12,  2 users,  load average: 0.15, 0.10, 0.08        # (1)!
Tasks: 187 total,   1 running, 185 sleeping,   0 stopped,   1 zombie              # (2)!
%Cpu(s):  5.2 us,  1.3 sy,  0.0 ni, 92.8 id,  0.7 wa,  0.0 hi,  0.0 si,  0.0 st   # (3)!
MiB Mem :  15826.1 total,  8234.5 free,  4127.9 used,  3463.7 buff/cache
MiB Swap:   2048.0 total,  2048.0 free,     0.0 used.  10834.6 avail Mem
```

1. Uptime and load averages (1-, 5-, 15-minute).
2. Process states at a glance.
3. CPU breakdown: user, system, idle, wait (I/O), etc.

**`wa` (wait)** above 5-10% indicates an I/O bottleneck. **`us` (user)** high means application code is consuming CPU. **`sy` (system)** high means kernel activity — often disk or network.

### htop — If Available

`htop` is a friendlier alternative with color, a tree view, and mouse support. Install it if it's not there (`dnf install htop` / `apt install htop`). Use it exactly like `top` but with arrow keys to navigate and F-keys for actions.

---

## Finding Processes

``` bash title="Finding Specific Processes"
pgrep nginx                # (1)!
# 445
# 446

pgrep -la nginx            # (2)!
# 445 nginx: master process /usr/sbin/nginx -g daemon off;
# 446 nginx: worker process

pgrep -u www-data          # (3)!

ps aux | grep "[n]ginx"    # (4)!

ss -tlnp | grep ":8080"    # (5)!
lsof -i :8080              # (6)!
```

1. By name — returns PIDs only.
2. By name, with command details.
3. By user.
4. By name using `ps`. The bracket trick (`[n]ginx`) stops `grep` from matching its own process.
5. Find the PID of whatever is listening on a port.
6. Same idea with `lsof`, if it's installed.

---

## Signals: Communicating With Processes

**Signals** are messages you send to a process to tell it to do something — stop, restart, reload configuration, or terminate.

``` bash title="Sending Signals"
kill PID              # (1)!
kill -9 PID           # (2)!
kill -1 PID           # (3)!
kill -STOP PID        # (4)!
kill -CONT PID        # (5)!

killall nginx         # (6)!
pkill -u jsmith       # (7)!
pkill -9 -u jsmith    # (8)!
```

1. Default: SIGTERM (15) — a polite request to stop.
2. SIGKILL — forceful, cannot be caught or ignored.
3. SIGHUP — reload configuration.
4. Pause the process (SIGSTOP).
5. Resume a paused process (SIGCONT).
6. SIGTERM to every process named `nginx`.
7. SIGTERM to all of jsmith's processes.
8. Forcefully kill all of jsmith's processes.

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
pgrep nginx        # (1)!
# 445

kill -HUP 445      # (2)!
kill -1 445        # (3)!
nginx -s reload    # (4)!
```

1. Find the process PID.
2. Send SIGHUP to reload the config without restarting.
3. Equivalently, by signal number.
4. nginx-specific wrapper for the same thing.

For services managed by systemd, `systemctl reload servicename` is the preferred approach — it handles the signal and verifies the reload succeeded.

---

## Background Jobs and Job Control

When you run a command, it runs in the foreground by default — your terminal is blocked until it finishes. Job control lets you manage multiple commands in one terminal session.

``` bash title="Job Control"
long-running-command &     # (1)!
# [1] 1234        ← job number and PID

^Z                         # (2)!
# [1]+  Stopped    long-running-command

bg %1                      # (3)!
fg %1                      # (4)!

jobs                       # (5)!
# [1]-  Running    long-running-command &
# [2]+  Stopped    another-command

kill %1                    # (6)!
```

1. Run a command in the background immediately.
2. Pause a running command and move it to the background — press `Ctrl+Z` while it's running.
3. Resume job 1 in the background.
4. Resume job 1 in the foreground.
5. List current jobs.
6. Kill a job by its job number.

### nohup — Survive Logout

By default, background jobs receive SIGHUP when you log out, killing them. `nohup` prevents this:

``` bash title="Using nohup"
nohup ./long-script.sh &                                  # (1)!
nohup ./long-script.sh > /var/log/myscript.log 2>&1 &     # (2)!
pgrep -la long-script                                     # (3)!
```

1. Sends output to `nohup.out` by default.
2. Better: send output to an explicit log file.
3. Check it's still running after you log out.

For long-running tasks, consider `tmux` or `screen` for persistent terminal sessions — they're more flexible than `nohup`.

---

## Common Scenarios

=== "Server Is Slow: Find the Culprit"

    The server feels sluggish. Find what's consuming resources.

    ``` bash title="Resource Investigation"
    ps aux --sort=-%cpu | head -10   # (1)!
    ps aux --sort=-%mem | head -10   # (2)!
    top                              # (3)!
    uptime                           # (4)!
    # load average: 8.45, 7.23, 6.12  ← high on a 4-core system
    top                              # (5)!
    iotop                            # (6)!
    # or: ps aux | awk '$8=="D"'   ← processes in disk wait
    ```

    1. Quick snapshot — who's consuming CPU?
    2. Who's consuming memory?
    3. Live view; press `P` to sort by CPU.
    4. Check load-average context.
    5. If load is high but CPU isn't, look for a high `wa` (I/O wait) in the CPU line.
    6. What's doing disk I/O? (`iotop` if installed.)

=== "Kill a Hung Process"

    An application is hung and won't respond to normal shutdown.

    ``` bash title="Kill a Hung Process"
    pgrep -la myapp        # (1)!
    # 1234 myapp --config /etc/myapp/config.yml
    kill 1234              # (2)!
    ps -p 1234             # (3)!
    kill -9 1234           # (4)!
    ps -p 1234             # (5)!
    ```

    1. Find the PID.
    2. Try graceful termination first, then wait ~10 seconds.
    3. Check if it's gone. If it's still there, escalate.
    4. Force kill.
    5. Verify it's gone — this should show nothing.

=== "Check What a Process Is Doing"

    You see a process consuming resources but don't know what it's doing.

    ``` bash title="Process Investigation"
    lsof -p 1234                              # (1)!
    lsof -p 1234 -i                           # (2)!
    ls -la /proc/1234/fd/                     # (3)!
    cat /proc/1234/cmdline | tr '\0' ' '      # (4)!
    cat /proc/1234/environ | tr '\0' '\n'     # (5)!
    ls -la /proc/1234/cwd                     # (6)!
    ```

    1. What files does it have open?
    2. What network connections does it have?
    3. The same open files, via `/proc`.
    4. What command started it?
    5. What environment variables does it have?
    6. What's its current working directory?

=== "Long-Running Job: Run and Detach"

    You need to run a script that takes hours and you need to log out.

    ``` bash title="Long-Running Jobs"
    nohup ./backup-script.sh > /var/log/backup.log 2>&1 &   # (1)!
    echo $!                                                 # (2)!
    disown                                                  # (3)!

    tmux new-session -s backup                              # (4)!
    # run your script inside tmux, then Ctrl+B, D to detach
    # later: tmux attach -t backup

    pgrep -la backup-script                                 # (5)!
    tail -f /var/log/backup.log
    ```

    1. Option 1 — `nohup` (simple): run detached, logging to a file.
    2. Print the PID so you can track it.
    3. Detach from the current shell so logging out doesn't signal it.
    4. Option 2 — `tmux` (better; you can reattach later).
    5. Check whether your background job is still running.

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
        ps aux --sort=-%cpu | head -3   # (1)!
        ps aux --sort=-%mem | head -3   # (2)!
        ps aux --sort=-%cpu | awk 'NR<=6 {printf "%-10s %-8s %-6s %-6s %s\n", $1, $2, $3, $4, $11}'   # (3)!
        ```

        1. Most CPU — `--sort` uses `ps` column names.
        2. Most memory.
        3. Or combined — show PID, user, CPU%, MEM%, and command.

??? question "Exercise 2: Gracefully Stop and Verify"
    Find the nginx master process PID, send it SIGTERM, wait, and verify it stopped.

    ??? tip "Solution"
        ``` bash title="Stop nginx Gracefully"
        pgrep -la nginx | grep master   # (1)!
        # 445 nginx: master process /usr/sbin/nginx
        kill 445                        # (2)!
        sleep 3                         # (3)!
        ps -p 445                       # (4)!
        pgrep nginx                     # (5)!
        # No output = no nginx processes running
        ```

        1. Find the master process PID.
        2. Send SIGTERM.
        3. Wait a moment...
        4. ...then verify — if it shows nothing, the process is gone.
        5. Or check via `pgrep` — no output means no nginx processes running.

        Note: In production, use `systemctl stop nginx` rather than killing directly — systemd handles the signal, verifies shutdown, and updates the service state.

??? question "Exercise 3: Background Job Management"
    Run `sleep 300` in the background, verify it's running, then pause it, then kill it.

    ??? tip "Solution"
        ``` bash title="Job Control Practice"
        sleep 300 &                          # (1)!
        # [1] 2345
        jobs                                 # (2)!
        # [1]+  Running    sleep 300 &
        ps -p 2345                           # (3)!
        kill -STOP 2345                      # (4)!
        ps -p 2345 -o pid,stat,command       # (5)!
        kill 2345                            # (6)!
        jobs                                 # (7)!
        # (empty)
        ```

        1. Start in the background.
        2. Verify it's running.
        3. Confirm via `ps` — shows the sleep process.
        4. Pause it.
        5. Check state — should show `T` (stopped).
        6. Kill it (or `kill %1` using the job number).
        7. Verify it's gone.

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

## What's Next?

You've covered four of the five Essentials categories. The commands from the command line, users and access, text pipelines, and process management are now in your toolkit.

The final Essentials category is **Bash Scripting** — where all of those commands become repeatable automation. Start with [Your First Bash Script](bash_first_script.md).

After completing Essentials, the **Efficiency** track covers the daily-use tools that experienced Linux professionals reach for: systemd for service management, `sed` for text transformation, and package management for keeping systems current.

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

