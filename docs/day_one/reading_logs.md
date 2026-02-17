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
    A["🚨 Something Is Broken"] --> B["Find the Logs<br/>ls -la /var/log/"]
    B --> C["View Recent Entries<br/>tail -100 logfile"]
    C --> D["Search for Errors<br/>grep -i error logfile"]
    D --> E{"Pattern Found?"}
    E -->|Yes| F["Narrow the Time Window<br/>journalctl --since"]
    E -->|No| G["Check Service Logs<br/>journalctl -u service"]
    G --> D
    F --> H["✅ Root Cause Identified"]

    style A fill:#c92a2a,stroke:#ff6b6b,color:#fff
    style H fill:#2f9e44,stroke:#51cf66,color:#fff
    style B fill:#2b6cb0,stroke:#2c5282,color:#fff
    style C fill:#2b6cb0,stroke:#2c5282,color:#fff
    style D fill:#2b6cb0,stroke:#2c5282,color:#fff
    style E fill:#d97706,stroke:#b45309,color:#fff
    style F fill:#2b6cb0,stroke:#2c5282,color:#fff
    style G fill:#2b6cb0,stroke:#2c5282,color:#fff
```

---

## Where Are the Logs?

Most logs live in `/var/log/`:

``` bash title="List Log Files"
ls -la /var/log/
```

**Common log files:**

| Log File | What It Contains |
|----------|------------------|
| `/var/log/syslog` or `/var/log/messages` | General system logs |
| `/var/log/auth.log` or `/var/log/secure` | Authentication (logins, sudo) |
| `/var/log/dmesg` | Kernel messages (hardware, boot) |
| `/var/log/nginx/` | Nginx access and error logs |
| `/var/log/apache2/` | Apache logs |
| `/var/log/mysql/` | MySQL/MariaDB logs |

**Application-specific logs** often live in:

- `/var/log/appname/`
- `/opt/appname/logs/`
- `/home/appuser/logs/`
- Wherever the app was configured to write them

Ask your team: "Where do the application logs live?" Every app is different.

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

    ``` bash title="Find All 500 Errors"
    grep '" 500 ' /var/log/nginx/access.log
    ```

=== ":material-alert-circle: Nginx Error Log"

    When something goes wrong server-side, it ends up here:

    ```
    2024/01/15 14:23:45 [error] 1234#0: *5678 connect() failed (111: Connection refused) while connecting to upstream
    ```

    Unlike access logs, error logs are descriptive — the `[error]` level and the message tell you directly what went wrong. Look for words like `failed`, `refused`, `timeout`, and `upstream`.

---

## The Essential Log Commands

=== ":material-arrow-down: View Recent Entries"

    **When to use:** Something just broke and you want to see the last few dozen log lines.

    Most recent entries are at the bottom of a log file — start there:

    ``` bash title="Last 20 Lines"
    tail -20 /var/log/syslog
    ```

    ``` bash title="Last 100 Lines (for more history)"
    tail -100 /var/log/nginx/error.log
    ```

    **Key insight:** The number after `tail` controls how many lines you see. Start with 20-50 for a quick look; go up to 500 if the problem started a while ago.

=== ":material-play: Watch Live"

    **When to use:** You want to reproduce the problem and watch errors appear in real-time.

    This is the killer feature — new log entries appear as they're written:

    ``` bash title="Follow Log in Real-Time"
    tail -f /var/log/nginx/access.log
    ```

    Trigger the problem (refresh the page, make an API call) and watch the entries appear live. Press `Ctrl+C` to stop.

    **Follow multiple logs at once:**

    ``` bash title="Watch Access and Error Logs Together"
    tail -f /var/log/nginx/access.log /var/log/nginx/error.log
    ```

    **Key insight:** Following multiple logs simultaneously lets you correlate access requests with errors — you can see which request triggered which error.

=== ":material-file-search: Browse Large Files"

    **When to use:** The log file is huge and you need to scroll around, search, or read it like a document.

    ``` bash title="Open Log in Browser"
    less /var/log/syslog
    ```

    **Navigation inside `less`:**

    | Key | Action |
    |-----|--------|
    | `G` | Jump to end (most recent entries) |
    | `g` | Jump to beginning |
    | `/error` | Search forward for "error" |
    | `n` | Next search match |
    | `N` | Previous search match |
    | `q` | Quit |

    **Key insight:** Press `G` immediately after opening a large log to jump to the most recent entries — you almost never want to start at the beginning.

=== ":material-arrow-up: Check the Start"

    **When to use:** You want to know when a log file was created, or check the log format before diving in.

    ``` bash title="First 20 Lines"
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

``` bash title="Find Error Lines"
grep -i "error" /var/log/syslog
```

**Key insight:** Always use `-i` unless you're intentionally filtering by case — logs are inconsistent about capitalisation (`error`, `Error`, and `ERROR` all appear in the wild).

### Find Errors with Context

**When to use:** You found an error but need to understand what led up to it. Errors rarely happen in isolation.

``` bash title="Show Context Around Errors"
grep -i -C 3 "error" /var/log/nginx/error.log
```

`-C 3` shows 3 lines before AND after each match. Use `-B` and `-A` separately when you need asymmetric context:

``` bash title="More History, Less After"
grep -i -B 5 -A 1 "error" /var/log/nginx/error.log
```

**Key insight:** The lines *before* an error are often more informative than the error line itself — they show what the system was doing when it failed.

### Recent Errors Only

**When to use:** The log file has been running for weeks and you only care about recent activity. Grepping a multi-gigabyte log is slow and buries current errors in historical noise.

``` bash title="Search Only Recent Log Entries"
tail -500 /var/log/nginx/error.log | grep -i "error"
```

**Key insight:** `tail` limits the data before `grep` even runs. Adjust the number to match how far back you need — `tail -100` for a quick check, `tail -2000` on a busy server where the problem started an hour ago.

### Find by Timestamp

**When to use:** You know roughly when something happened and want to narrow the search to that window.

First, check the timestamp format in your log — it varies between applications, and this is exactly where [checking the format first](#reading-common-log-formats) with `head` pays off:

``` bash title="Check Timestamp Format First"
head -3 /var/log/syslog
# Jan 15 14:23:45 prod-web-01 ...
```

Then grep for entries in that window:

``` bash title="Find Entries from Specific Time"
grep "Jan 15 14:" /var/log/syslog
```

**Key insight:** Be as specific as the format allows. `grep "14:"` is too broad; `grep "Jan 15 14:3"` narrows to a 10-minute window. For journalctl-managed logs, `--since` and `--until` (covered below) are usually easier.

### Search Multiple Files

**When to use:** You're not sure which log file contains the error, or you want to sweep an entire log directory at once.

``` bash title="Search All Logs in a Directory"
grep -r -i "connection refused" /var/log/nginx/
```

``` bash title="Search All System Logs"
grep -r -i "out of memory" /var/log/
```

**Key insight:** `-r` prefixes every match with its filename — useful for discovering *which* log file is actually capturing the errors you're hunting.

### Count Occurrences

**When to use:** You want to gauge the scale of a problem before diving into the details.

``` bash title="Count Error Occurrences"
grep -c "connection refused" /var/log/syslog
# 47
```

**Key insight:** Start with `-c` to understand severity. Three occurrences might be noise; 47 in the last hour is worth dropping everything for. Once you know the scale, remove the `-c` to read the actual lines.

---

## journalctl - The Modern Log Tool

On systems using systemd (most modern Linux), `journalctl` is incredibly powerful.

!!! tip "Access Requirements"
    On many systems, `journalctl` without `sudo` only shows logs for your own user. If you're getting empty output or "permission denied" errors, either run it with `sudo`, or ask your team to add you to the `systemd-journal` group — which grants read access to all system logs without needing full sudo.

### View All Recent Logs

``` bash title="Recent System Logs"
journalctl -n 50
```

Shows the last 50 log entries from all services.

### Follow Logs in Real-Time

``` bash title="Follow All Logs"
journalctl -f
```

Like `tail -f` but for all system logs at once.

### View Logs for a Specific Service

This is where journalctl shines:

``` bash title="Nginx Logs Only"
journalctl -u nginx
```

``` bash title="MySQL Logs Only"
journalctl -u mysql
```

``` bash title="SSH Logs Only"
journalctl -u sshd
```

### Logs Since a Specific Time

``` bash title="Logs from the Last Hour"
journalctl --since "1 hour ago"
```

``` bash title="Logs from Today"
journalctl --since today
```

``` bash title="Logs from Specific Time Range"
journalctl --since "2024-01-15 14:00" --until "2024-01-15 15:00"
```

### Show Only Errors and Warnings

``` bash title="Errors and Above"
journalctl -p err
```

Priority levels: `emerg`, `alert`, `crit`, `err`, `warning`, `notice`, `info`, `debug`

### Combine Service and Time

``` bash title="Recent Nginx Errors"
journalctl -u nginx --since "1 hour ago" -p err
```

This command says: "Show me nginx errors from the last hour."

---

## Log Analysis Patterns

Pick the scenario that matches your situation:

=== ":material-clock-alert: Something Broke at 2:30pm"

    **Goal:** Find out what was happening on the server around a specific time.

    ``` bash title="Investigate a Time Window"
    journalctl --since "14:25" --until "14:35"
    ```

    Or grep a log file directly if you know the format:

    ``` bash title="Grep for Time Window in Syslog"
    grep "14:3" /var/log/syslog | less
    ```

    **Key insight:** Check the log format first (with `head`) so you know what timestamp pattern to grep for — it varies between applications.

=== ":material-repeat: The App Keeps Crashing"

    **Goal:** Find which error is happening most often so you know where to start.

    ``` bash title="Find Most Common Errors"
    grep -i "error" /var/log/app/error.log | sort | uniq -c | sort -rn | head -20
    ```

    **What this does:** `sort` groups identical lines together, `uniq -c` counts them, `sort -rn` puts the most frequent first. Start investigating from the top.

=== ":material-calendar-search: When Did This Start?"

    **Goal:** Find the very first occurrence of an error to establish a timeline.

    ``` bash title="Find First Occurrence"
    grep -m 1 "connection refused" /var/log/syslog
    ```

    `-m 1` stops after the first match — without it, `grep` would print every occurrence. Once you have a timestamp, you can correlate it with deployments, config changes, or traffic spikes.

=== ":material-eye: Is It Still Happening?"

    **Goal:** Watch live to see if errors are still occurring right now.

    ``` bash title="Watch for Specific Error in Real-Time"
    tail -f /var/log/syslog | grep --line-buffered "error"
    ```

    `--line-buffered` ensures matches appear immediately rather than waiting for a full buffer. If no new lines appear after reproducing the problem, you may be looking at the wrong log file.

---

## Accessing Protected Logs

Some logs are owned by root or a restricted group and will return "Permission denied" when you try to read them directly. You have two options:

``` bash title="View Protected Logs with Sudo"
sudo tail -100 /var/log/secure
sudo journalctl -u sshd
```

Or, if you're in the `adm` group, you already have read access to most system logs without needing `sudo`. Check with `groups` — if `adm` isn't listed, ask your team to add you. See [Understanding Your Permissions](permissions.md) for how groups and log access work together.

---

## Quick Reference

### Most Used Commands

``` bash title="Log Reading Cheat Sheet"
# Last 100 lines of a log
tail -100 /var/log/syslog

# Follow log in real-time
tail -f /var/log/nginx/error.log

# Search for errors
grep -i "error" /var/log/syslog

# Service logs (systemd)
journalctl -u nginx -n 100

# Recent errors only
journalctl --since "1 hour ago" -p err

# Follow service logs
journalctl -u nginx -f
```

### Log Locations Cheat Sheet

| What You're Looking For | Where to Look |
|------------------------|---------------|
| General system events | `/var/log/syslog` or `journalctl` |
| Authentication/logins | `/var/log/auth.log` or `journalctl -u sshd` |
| Web server | `/var/log/nginx/` or `/var/log/apache2/` |
| Database | `/var/log/mysql/` or `journalctl -u mysql` |
| Application | Ask your team! |

---

## Practice Exercises

??? question "Exercise 1: Find Recent Authentication Failures"
    You've been told that someone may be attempting to brute-force SSH logins. Check the last 200 lines of `/var/log/auth.log` and search for failed login attempts.

    **Hint:** Pipe `tail` into `grep`. The word to search for is "Failed".

    ??? tip "Which log file?"
        On **Debian/Ubuntu**, authentication events are in `/var/log/auth.log`. On **RHEL/CentOS/Fedora**, the same file is `/var/log/secure`. Either way, the `grep` command and output are identical.

    ??? tip "Solution"
        ```bash title="Find Recent SSH Failures"
        tail -200 /var/log/auth.log | grep "Failed"
        ```

        You'll see lines like:
        ```
        Jan 15 14:23:11 prod-web-01 sshd[1234]: Failed password for invalid user admin from 192.168.1.100 port 54321 ssh2
        ```

        Multiple failures from one IP address is a sign of a brute-force attempt. Report it to your security team.

??? question "Exercise 2: Find the Most Frequent Errors Today"
    The app has been logging errors all day. Use `journalctl` to get today's errors for the `nginx` service, then find which error message appears most often.

    **Hint:** Combine `journalctl`, `grep`, `sort`, `uniq -c`, and `sort -rn`.

    ??? tip "Solution"
        ```bash title="Most Common Nginx Errors Today"
        journalctl -u nginx --since today -p err | sort | uniq -c | sort -rn | head -10
        ```

        `uniq -c` counts consecutive identical lines. `sort -rn` orders by count descending. The most common error appears first — start there.

??? question "Exercise 3: Investigate a Time Window"
    Your team lead says the app started throwing errors around 2:30pm. Use `journalctl` to show all system logs from 2:25pm to 2:40pm today.

    **Hint:** Use `--since` and `--until` with time strings.

    ??? tip "Solution"
        ```bash title="Investigate Time Window"
        journalctl --since "14:25" --until "14:40"
        ```

        **Alternative** — grep a log file directly:
        ```bash title="Grep Time Window in Syslog"
        grep "14:2[5-9]\|14:3" /var/log/syslog | less
        ```

---

## Quick Recap

**Start with the basics:**

1. `tail -f /var/log/app.log` — Watch in real-time
2. `grep "error"` — Find the bad stuff
3. `journalctl -u servicename` — Service-specific logs

**Add context:**

- Use `-B` and `-A` with grep for surrounding lines
- Use `--since` with journalctl for time windows
- Combine `tail` and `grep` for recent errors

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

You can read logs like a pro. The next skill is knowing where to find the team wiki, runbooks, and who to ask when logs alone aren't enough. **Finding Documentation** is coming soon. In the meantime, head back to the [Day One Overview](overview.md) to review the full series.

!!! tip "Logs Tell Stories"
    Every log entry is a breadcrumb. Errors rarely happen in isolation — there's usually a chain of events. Learn to read that story, and debugging becomes much easier.
