---
title: Reading Linux Logs Like a Pro
description: Learn to debug production Linux systems by reading log files. Master tail, grep, and journalctl to find errors, track issues, and diagnose problems fast.
---

# Reading Logs Like a Pro

!!! tip "Part of Day One"
    This is the fifth article in the [Day One: Getting Started](overview.md) series. You should have already completed [Getting Access](getting_access.md), [Orientation](orientation.md), [Understanding Your Permissions](permissions.md), and [Safe Exploration](safe_exploration.md).

Something broke. The app is throwing errors. Users are complaining. Your team lead says, "Can you check the logs?"

And now you're staring at files full of timestamps and cryptic messages wondering where to even begin.

**Let's fix that.**

Reading logs is probably the most important skill for debugging production systems. Once you get comfortable with it, you'll be able to diagnose problems in minutes instead of hours.

## The Investigation Workflow

``` mermaid
graph TD
    A["🚨 Something Is Broken"] --> B["Check Service Logs<br/>journalctl -u service"]
    B --> C["Filter by Priority<br/>journalctl -p err"]
    C --> D{"Pattern Found?"}
    D -->|Yes| E["Narrow Time Window<br/>journalctl --since/--until"]
    D -->|No| F["Check Flat File Logs<br/>tail /var/log/app/"]
    F --> G["Search with grep<br/>grep -i error logfile"]
    G --> D
    E --> H["✅ Root Cause Identified"]

    style A fill:#1a202c,stroke:#cbd5e0,stroke-width:2px,color:#fff
    style B fill:#2d3748,stroke:#cbd5e0,stroke-width:2px,color:#fff
    style C fill:#2d3748,stroke:#cbd5e0,stroke-width:2px,color:#fff
    style D fill:#4a5568,stroke:#cbd5e0,stroke-width:2px,color:#fff
    style E fill:#2d3748,stroke:#cbd5e0,stroke-width:2px,color:#fff
    style F fill:#2d3748,stroke:#cbd5e0,stroke-width:2px,color:#fff
    style G fill:#2d3748,stroke:#cbd5e0,stroke-width:2px,color:#fff
    style H fill:#d69e2e,stroke:#cbd5e0,stroke-width:2px,color:#000
```

---

## Where Are the Logs?

On modern enterprise Linux (RHEL 8+, Ubuntu 22.04+, Debian 12+), logs come from two sources — and knowing which to reach for first matters.

**systemd-journald** collects logs from every service, the kernel, and the boot process into a structured binary journal. It's always running. `journalctl` is how you read it. For any system service issue, start here.

**Flat log files** in `/var/log/` are written by applications that manage their own logging — nginx, Apache, MySQL, and your own application code. These exist regardless of journald.

!!! tip "Does /var/log/syslog exist on your server?"
    On older systems, `rsyslog` bridges journald into `/var/log/syslog` or `/var/log/messages`. On many modern minimal installs, rsyslog isn't installed and those files simply don't exist. That's normal. Use `journalctl` for system events instead.

| You're investigating... | Start with |
|------------------------|------------|
| A system service (nginx, sshd, your app) | `journalctl -u servicename` |
| Authentication failures | `journalctl -u sshd` |
| Kernel / hardware events | `journalctl -k` |
| App flat files (nginx access logs, custom logs) | `tail`, `grep` on `/var/log/appname/` |
| Not sure where to start | `journalctl -p err --since "1 hour ago"` |

**Application-specific flat file logs** often live in:

- `/var/log/appname/`
- `/opt/appname/logs/`
- `/home/appuser/logs/`
- Wherever the app was configured to write them

Ask your team: "Where do the application logs live?" Every app is different.

---

## journalctl — System and Service Logs

On modern Linux, `journalctl` is your primary log tool. Every service managed by systemd sends its output to the journal automatically — no log file path to find, no permission hunting.

!!! tip "Access Requirements"
    On many systems, `journalctl` without `sudo` only shows logs for your own user. If you're getting empty output or "permission denied" errors, either run it with `sudo`, or ask your team to add you to the `systemd-journal` group — which grants read access to all system logs without needing full sudo.

### Logs for a Specific Service

This is where journalctl shines — no hunting for the right log file:

``` bash title="Nginx Logs Only" linenums="1"
journalctl -u nginx
```

``` bash title="MySQL Logs Only" linenums="1"
journalctl -u mysql
```

``` bash title="SSH Logs Only" linenums="1"
journalctl -u sshd
```

### View All Recent Logs

``` bash title="Recent System Logs" linenums="1"
journalctl -n 50
```

Shows the last 50 log entries from all services.

### Follow Logs in Real-Time

``` bash title="Follow All Logs" linenums="1"
journalctl -f
```

Like `tail -f` but for all system logs at once. Add `-u servicename` to follow one service.

### Show Only Errors and Warnings

``` bash title="Errors and Above" linenums="1"
journalctl -p err
```

Priority levels: `emerg`, `alert`, `crit`, `err`, `warning`, `notice`, `info`, `debug`

### Logs Since a Specific Time

``` bash title="Logs from the Last Hour" linenums="1"
journalctl --since "1 hour ago"
```

``` bash title="Logs from Today" linenums="1"
journalctl --since today
```

``` bash title="Logs from Specific Time Range" linenums="1"
journalctl --since "2024-01-15 14:00" --until "2024-01-15 15:00"
```

### Combine Service, Time, and Priority

``` bash title="Recent Nginx Errors" linenums="1"
journalctl -u nginx --since "1 hour ago" -p err
```

This is usually the right starting point for any service problem: narrow by service, time, and severity in one command.

---

## Reading Common Log Formats

Before reaching for `tail` or `grep`, it helps to know what you're looking at. Log formats vary by application — here are the three most common:

=== ":material-text-box-outline: Syslog Format"

    General system events from Linux itself and most services follow this format:

    ```
    Jan 15 14:23:45 prod-web-01 nginx[1234]: 2024/01/15 14:23:45 [error] ...
    ```

    | Part | Meaning |
    |------|---------|
    | `Jan 15 14:23:45` | Timestamp |
    | `prod-web-01` | Hostname (useful when logs are aggregated from multiple servers) |
    | `nginx[1234]` | Service name and process ID |
    | Everything after `:` | The actual message |

=== ":material-web: Nginx Access Log"

    Every HTTP request to your server leaves a line here:

    ```
    192.168.1.50 - - [15/Jan/2024:14:23:45 +0000] "GET /api/users HTTP/1.1" 200 1234 "-" "Mozilla/5.0..."
    ```

    | Part | Meaning |
    |------|---------|
    | `192.168.1.50` | Client IP address |
    | `[15/Jan/2024:14:23:45 +0000]` | Timestamp |
    | `"GET /api/users HTTP/1.1"` | HTTP method, path, and protocol |
    | `200` | HTTP status code |
    | `1234` | Response size in bytes |

    **What to look for:**

    - `4xx` codes — Client errors (404 not found, 401 unauthorized)
    - `5xx` codes — Server errors (500 internal error, 502 bad gateway)

    ``` bash title="Find All 500 Errors" linenums="1"
    grep '" 500 ' /var/log/nginx/access.log
    ```

=== ":material-alert-circle: Nginx Error Log"

    When something goes wrong server-side, it ends up here:

    ```
    2024/01/15 14:23:45 [error] 1234#0: *5678 connect() failed (111: Connection refused) while connecting to upstream
    ```

    Unlike access logs, error logs are descriptive — the `[error]` level and the message tell you directly what went wrong. Look for words like `failed`, `refused`, `timeout`, and `upstream`.

---

## Flat File Log Commands

For application logs that write directly to `/var/log/` — nginx access logs, database logs, custom application output — use these tools. They also work on any service where flat files exist alongside journald.

=== ":material-arrow-down: View Recent Entries"

    **When to use:** Something just broke and you want to see the last few dozen log lines.

    Most recent entries are at the bottom of a log file — start there:

    ``` bash title="Last 20 Lines" linenums="1"
    tail -20 /var/log/syslog
    ```

    ``` bash title="Last 100 Lines (for more history)" linenums="1"
    tail -100 /var/log/nginx/error.log
    ```

    **Key insight:** The number after `tail` controls how many lines you see. Start with 20-50 for a quick look; go up to 500 if the problem started a while ago.

=== ":material-play: Watch Live"

    **When to use:** You want to reproduce the problem and watch errors appear in real-time.

    This is the killer feature — new log entries appear as they're written:

    ``` bash title="Follow Log in Real-Time" linenums="1"
    tail -f /var/log/nginx/access.log
    ```

    Trigger the problem (refresh the page, make an API call) and watch the entries appear live. Press `Ctrl+C` to stop.

    **Follow multiple logs at once:**

    ``` bash title="Watch Access and Error Logs Together" linenums="1"
    tail -f /var/log/nginx/access.log /var/log/nginx/error.log
    ```

    **Key insight:** Following multiple logs simultaneously lets you correlate access requests with errors — you can see which request triggered which error.

=== ":material-file-search: Browse Large Files"

    **When to use:** The log file is huge and you need to scroll around, search, or read it like a document.

    ``` bash title="Open Log in Browser" linenums="1"
    less /var/log/syslog
    ```

    **Navigation inside `less`:**

    | Key | Action |
    |-----|--------|
    | `Space` | Page down |
    | `b` | Page up |
    | `G` | **Jump to end (most recent entries)** |
    | `g` | Jump to beginning |
    | `/pattern` | Search forward |
    | `n` | Next search match |
    | `N` | Previous search match |
    | `q` | Quit |

    **Key insight:** Press `G` immediately after opening a large log to jump to the most recent entries — you almost never want to start at the beginning.

=== ":material-arrow-up: Check the Start"

    **When to use:** You want to know when a log file was created, or check the log format before diving in.

    ``` bash title="First 20 Lines" linenums="1"
    head -20 /var/log/syslog
    ```

    **Key insight:** `head` is most useful for confirming the timestamp format a log uses before you try to `grep` for a specific time window — log formats vary between applications.

---

## Searching Logs with grep

`grep` is your search tool — it finds lines in a log file that match a pattern. Here are the flags you'll reach for most often:

| Flag | What It Does |
|------|--------------|
| `-i` | Case-insensitive (`error`, `Error`, `ERROR` all match) |
| `-C N` | Show N lines of **C**ontext before AND after each match |
| `-B N` | Show N lines **B**efore each match |
| `-A N` | Show N lines **A**fter each match |
| `-c` | **C**ount matches instead of printing them |
| `-m N` | Stop after the first **N** matches |
| `-r` | Search **r**ecursively through a directory |
| `--line-buffered` | Flush output immediately (required when piping to another command) |

### Find All Errors

**When to use:** You want to see every line in a log file that mentions an error.

``` bash title="Find Error Lines" linenums="1"
grep -i "error" /var/log/syslog
```

**Key insight:** Always use `-i` unless you're intentionally filtering by case — logs are inconsistent about capitalisation (`error`, `Error`, and `ERROR` all appear in the wild).

### Find Errors with Context

**When to use:** You found an error but need to understand what led up to it. Errors rarely happen in isolation.

``` bash title="Show Context Around Errors" linenums="1"
grep -i -C 3 "error" /var/log/nginx/error.log  # (1)!
```

1. `-C 3` shows 3 lines of **C**ontext before AND after each match. Errors rarely happen in isolation — the surrounding lines show what the system was doing when it failed.

`-C 3` shows 3 lines before AND after each match. Use `-B` and `-A` separately when you need asymmetric context:

``` bash title="More History, Less After" linenums="1"
grep -i -B 5 -A 1 "error" /var/log/nginx/error.log
```

**Key insight:** The lines *before* an error are often more informative than the error line itself — they show what the system was doing when it failed.

### Recent Errors Only

**When to use:** The log file has been running for weeks and you only care about recent activity. Grepping a multi-gigabyte log is slow and buries current errors in historical noise.

``` bash title="Search Only Recent Log Entries" linenums="1"
tail -500 /var/log/nginx/error.log | grep -i "error"
```

**Key insight:** `tail` limits the data before `grep` even runs. Adjust the number to match how far back you need — `tail -100` for a quick check, `tail -2000` on a busy server where the problem started an hour ago.

### Find by Timestamp

**When to use:** You know roughly when something happened and want to narrow the search to that window.

First, check the timestamp format in your log — it varies between applications, and this is exactly where [checking the format first](#reading-common-log-formats) with `head` pays off:

``` bash title="Check Timestamp Format First" linenums="1"
head -3 /var/log/syslog
# Jan 15 14:23:45 prod-web-01 ...
```

Then grep for entries in that window:

``` bash title="Find Entries from Specific Time" linenums="1"
grep "Jan 15 14:" /var/log/syslog
```

**Key insight:** Be as specific as the format allows. `grep "14:"` is too broad; `grep "Jan 15 14:3"` narrows to a 10-minute window. For journalctl-managed logs, `--since` and `--until` (covered below) are usually easier.

### Search Multiple Files

**When to use:** You're not sure which log file contains the error, or you want to sweep an entire log directory at once.

``` bash title="Search All Logs in a Directory" linenums="1"
grep -r -i "connection refused" /var/log/nginx/
```

``` bash title="Search All System Logs" linenums="1"
grep -r -i "out of memory" /var/log/
```

**Key insight:** `-r` prefixes every match with its filename — useful for discovering *which* log file is actually capturing the errors you're hunting.

### Count Occurrences

**When to use:** You want to gauge the scale of a problem before diving into the details.

``` bash title="Count Error Occurrences" linenums="1"
grep -c "connection refused" /var/log/syslog
# 47
```

**Key insight:** Start with `-c` to understand severity. Three occurrences might be noise; 47 in the last hour is worth dropping everything for. Once you know the scale, remove the `-c` to read the actual lines.

---

## Log Analysis Patterns

Pick the scenario that matches your situation:

=== ":material-clock-alert: Something Broke at 2:30pm"

    **Goal:** Find out what was happening on the server around a specific time.

    ``` bash title="Investigate a Time Window" linenums="1"
    journalctl --since "14:25" --until "14:35"
    ```

    Or grep a log file directly if you know the format:

    ``` bash title="Grep for Time Window in Syslog" linenums="1"
    grep "14:3" /var/log/syslog | less
    ```

    **Key insight:** Check the log format first (with `head`) so you know what timestamp pattern to grep for — it varies between applications.

=== ":material-repeat: The App Keeps Crashing"

    **Goal:** Find which error is happening most often so you know where to start.

    If your app is a systemd service:

    ``` bash title="Find Most Common Errors (systemd service)" linenums="1"
    journalctl -u myapp --since today -p err | sort | uniq -c | sort -rn | head -10
    ```

    If your app writes flat log files:

    ``` bash title="Find Most Common Errors (flat log file)" linenums="1"
    grep -i "error" /var/log/app/error.log | sort | uniq -c | sort -rn | head -20
    ```

    **What this does:** `sort` groups identical lines together, `uniq -c` counts them, `sort -rn` puts the most frequent first. Start investigating from the top.

=== ":material-calendar-search: When Did This Start?"

    **Goal:** Find the very first occurrence of an error to establish a timeline.

    ``` bash title="Find First Occurrence" linenums="1"
    grep -m 1 "connection refused" /var/log/syslog  # (1)!
    ```

    1. `-m 1` stops after the first **m**atch. On a log file with hundreds of occurrences, this returns immediately with just the earliest entry — the timestamp that starts your timeline.

    `-m 1` stops after the first match — without it, `grep` would print every occurrence. Once you have a timestamp, you can correlate it with deployments, config changes, or traffic spikes.

=== ":material-eye: Is It Still Happening?"

    **Goal:** Watch live to see if errors are still occurring right now.

    If your app is a systemd service, follow the journal directly:

    ``` bash title="Watch Service Logs Live" linenums="1"
    journalctl -u myapp -f
    ```

    For flat log files, filter the stream with grep:

    ``` bash title="Watch for Specific Error in Real-Time" linenums="1"
    tail -f /var/log/syslog | grep --line-buffered "error"  # (1)!
    ```

    1. `--line-buffered` flushes grep's output after every matching line instead of waiting to fill an internal buffer. Without it, matches may not appear for seconds — or at all — when output is piped.

    Trigger the problem and watch. If no new lines appear, you may be looking at the wrong log source.

---

## Accessing Protected Logs

Some logs are owned by root or a restricted group and will return "Permission denied" when you try to read them directly. You have two options:

``` bash title="View Protected Logs with Sudo" linenums="1"
sudo tail -100 /var/log/secure
sudo journalctl -u sshd
```

Or, if you're in the `adm` group, you already have read access to most system logs without needing `sudo`. Check with `groups` — if `adm` isn't listed, ask your team to add you. See [Understanding Your Permissions](permissions.md) for how groups and log access work together.

---

## Quick Reference

### Most Used Commands

``` bash title="Log Reading Cheat Sheet" linenums="1"
# Service logs — start here on modern systems
journalctl -u nginx -n 100

# Follow service logs live
journalctl -u nginx -f

# Recent errors from any service
journalctl -p err --since "1 hour ago"

# Flat file logs — for app-specific files
tail -100 /var/log/nginx/error.log
tail -f /var/log/nginx/access.log

# Search a flat file
grep -i "error" /var/log/nginx/error.log
```

### Log Locations Cheat Sheet

| What You're Looking For | Where to Look |
|------------------------|---------------|
| General system events | `journalctl` |
| Authentication/logins | `journalctl -u sshd` or `/var/log/auth.log` |
| Web server | `journalctl -u nginx` or `/var/log/nginx/` |
| Database | `journalctl -u mysql` or `/var/log/mysql/` |
| Application | Ask your team! |

---

## Practice Problems

??? question "Problem 1: Find Recent Authentication Failures"
    You've been told that someone may be attempting to brute-force SSH logins. Find recent failed login attempts.

    **Hint:** On modern systems, `sshd` logs to the journal. On older systems, check `/var/log/auth.log` or `/var/log/secure`.

    ??? tip "Answer"
        On modern systems, start with journalctl:

        ```bash title="Find Recent SSH Failures (journalctl)" linenums="1"
        journalctl -u sshd --since "1 hour ago" | grep "Failed"
        ```

        On older systems with flat log files:

        ```bash title="Find Recent SSH Failures (flat log)" linenums="1"
        tail -200 /var/log/auth.log | grep "Failed"
        # On RHEL/Fedora: tail -200 /var/log/secure | grep "Failed"
        ```

        You'll see lines like:
        ```
        Jan 15 14:23:11 prod-web-01 sshd[1234]: Failed password for invalid user admin from 192.168.1.100 port 54321 ssh2
        ```

        Multiple failures from one IP address is a sign of a brute-force attempt. Report it to your security team.

??? question "Problem 2: Find the Most Frequent Errors Today"
    The app has been logging errors all day. Use `journalctl` to get today's errors for the `nginx` service, then find which error message appears most often.

    **Hint:** Combine `journalctl`, `grep`, `sort`, `uniq -c`, and `sort -rn`.

    ??? tip "Answer"
        ```bash title="Most Common Nginx Errors Today" linenums="1"
        journalctl -u nginx --since today -p err | sort | uniq -c | sort -rn | head -10
        ```

        `uniq -c` counts consecutive identical lines. `sort -rn` orders by count descending. The most common error appears first — start there.

??? question "Problem 3: Investigate a Time Window"
    Your team lead says the app started throwing errors around 2:30pm. Use `journalctl` to show all system logs from 2:25pm to 2:40pm today.

    **Hint:** Use `--since` and `--until` with time strings.

    ??? tip "Answer"
        ```bash title="Investigate Time Window" linenums="1"
        journalctl --since "14:25" --until "14:40"
        ```

        **Alternative** — grep a log file directly:
        ```bash title="Grep Time Window in Syslog" linenums="1"
        grep "14:2[5-9]\|14:3" /var/log/syslog | less
        ```

---

## Quick Recap

**Start with the basics:**

1. `journalctl -u servicename -f` — Follow a service's logs in real-time
2. `journalctl -p err --since "1 hour ago"` — Find recent errors across all services
3. `tail -f /var/log/app.log` + `grep` — For flat log files your app writes directly

**Add context:**

- Use `-B` and `-A` with grep for surrounding lines
- Use `--since` and `--until` with journalctl for time windows
- Filter journalctl by service (`-u`), priority (`-p`), and time together

**Think like a detective:**

- When did it start?
- How often is it happening?
- What's the pattern?

---

## Further Reading

### Command References

- `man tail` — Full options for `tail`; `--retry` is useful when following logs that rotate during an active `tail -f`
- `man journalctl` — Comprehensive reference; the `-o` output format options and `--output-fields` are particularly powerful
- `man grep` — Full grep documentation; `-C` for context lines, `-P` for Perl-compatible regex in complex patterns

### Deep Dives

- [Brendan Gregg - Linux Performance](https://www.brendangregg.com/linuxperf.html) — When logs point to performance issues, this is the definitive next stop

### Official Documentation

- [systemd journalctl](https://www.freedesktop.org/software/systemd/man/latest/journalctl.html) — Authoritative journalctl reference from the systemd project
- [Red Hat: Viewing and Managing Log Files](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/configuring_basic_system_settings/assembly_viewing-and-managing-log-files_configuring-basic-system-settings) — RHEL-specific log management guide

### Related Articles

- [Orientation](orientation.md) — Covers `hostname` and system identification if you're not sure which server's logs you're looking at
- [Safe Exploration](safe_exploration.md) — Finding where application logs are stored on an unfamiliar server

## What's Next?

You can read logs like a pro. Next: [Finding Documentation](finding_docs.md) — how to understand an unfamiliar server using `man` pages, README files, git history, and what the system itself tells you.
