---
title: Common First Tasks on a Linux Server
description: "Walk through the real tasks you'll be asked to do on Day One: checking service status, reading logs, inspecting configs, and verifying system health."
---

# Common First Tasks

!!! tip "Part of Day One"
    This is the seventh article in the [Day One: Getting Started](overview.md) series. You should have already completed [Getting Access](getting_access.md), [Orientation](orientation.md), [Understanding Your Permissions](permissions.md), [Safe Exploration](safe_exploration.md), [Reading Logs](reading_logs.md), and [Finding Documentation](finding_docs.md).

Your team lead sends you a message: *"Can you check if the API service is running?"*

Or: *"The logs should show what's wrong."*

Or: *"Just verify the config looks correct."*

These are the tasks you'll actually be asked to do on your first day with a new server. Let's walk through them.

---

## Checking If a Service Is Running

**The ask:** "Is nginx running?" / "Can you check if the app is up?"

### Using systemctl (Modern Linux)

``` bash title="Check Service Status"
systemctl status nginx
```

**What to look for:**

```
● nginx.service - A high performance web server
   Loaded: loaded (/lib/systemd/system/nginx.service; enabled)
   Active: active (running) since Mon 2024-01-15 10:00:00 UTC; 5 days ago
   Main PID: 1234 (nginx)
```

- `Active: active (running)` — It's running ✅
- `Active: inactive (dead)` — It's stopped ❌
- `Active: failed` — It crashed ❌

### Check Multiple Services

``` bash title="Check Common Services"
systemctl status nginx
systemctl status mysql
systemctl status redis
systemctl status docker
```

### Is It Listening on the Expected Port?

A service can be "running" but not actually accepting connections:

``` bash title="Check Listening Ports"
ss -tlnp | grep nginx
# or
netstat -tlnp | grep :80
```

**What you want to see:**

```
LISTEN  0  511  0.0.0.0:80  0.0.0.0:*  users:(("nginx",pid=1234,fd=6))
```

If nothing shows up, the service isn't listening.

---

## Tailing Application Logs

**The ask:** "Check the logs and see what's happening"

Log reading is covered in depth in [Reading Logs Like a Pro](reading_logs.md). Here are the quick commands for checking logs as part of a task:

``` bash title="Follow Logs in Real-Time"
tail -f /var/log/nginx/error.log
```

Reproduce the problem and watch for new entries. Press `Ctrl+C` to stop.

``` bash title="Service Logs with journalctl"
journalctl -u nginx -f
journalctl -u app-name --since "10 minutes ago"
```

For time-windowed searches, common log formats, and error pattern analysis, see [Reading Logs Like a Pro](reading_logs.md).

---

## Finding Configuration Files

**The ask:** "Can you check the config for [setting]?"

### Common Config Locations

| Application | Config Location |
|-------------|-----------------|
| Nginx | `/etc/nginx/nginx.conf`, `/etc/nginx/sites-enabled/` |
| Apache | `/etc/apache2/apache2.conf`, `/etc/apache2/sites-enabled/` |
| MySQL | `/etc/mysql/my.cnf` |
| PostgreSQL | `/etc/postgresql/*/main/postgresql.conf` |
| SSH | `/etc/ssh/sshd_config` |
| System | `/etc/` (most things) |
| Applications | `/opt/app-name/config/`, `/var/www/app/config/` |

### Read a Config File

``` bash title="View Config"
cat /etc/nginx/nginx.conf
# or for large files
less /etc/nginx/nginx.conf
```

### Search for a Specific Setting

``` bash title="Find Setting in Config"
grep -r "worker_processes" /etc/nginx/
grep -r "database" /var/www/app/config/
```

### Check Config Syntax (Before Changes)

Many services can validate their config:

``` bash title="Validate Config (Read-Only)"
nginx -t
# nginx: configuration file /etc/nginx/nginx.conf syntax is ok
# nginx: configuration file /etc/nginx/nginx.conf test is successful

apache2ctl configtest
mysql --help --verbose | grep "Default options"
```

---

## Checking What's Using Resources

**The ask:** "The server is slow, can you see what's happening?"

### CPU and Memory Overview

``` bash title="Live System Monitor"
top
```

**Quick reads:**

- Look at the top processes — are any using 100% CPU?
- Check memory (Mem line) — is it nearly full?
- Check load average — above 1.0 per core means busy

Press `q` to exit.

### Find the Hungry Processes

``` bash title="Top CPU Consumers"
ps aux --sort=-%cpu | head -10
```

``` bash title="Top Memory Consumers"
ps aux --sort=-%mem | head -10
```

### Check Disk Space

``` bash title="Disk Usage"
df -h
```

**Red flag:** Any filesystem at 90%+ usage.

### What's Using All the Disk?

``` bash title="Find Large Directories"
du -sh /* 2>/dev/null | sort -hr | head -10
```

Then drill down:

``` bash title="Drill Into Large Directory"
du -sh /var/* 2>/dev/null | sort -hr | head -10
```

---

## Checking Database Connectivity

**The ask:** "Is the app connecting to the database?"

### Test MySQL/MariaDB Connection

``` bash title="Test MySQL Connection"
mysql -h localhost -u appuser -p -e "SELECT 1;"
```

If it connects, the database is accessible.

### Test PostgreSQL Connection

``` bash title="Test PostgreSQL Connection"
psql -h localhost -U appuser -d dbname -c "SELECT 1;"
```

### Check from Application Perspective

Look in the app logs for database errors:

``` bash title="Find Database Errors in Logs"
grep -i "database\|mysql\|postgres\|connection" /var/log/app/error.log
```

Common errors:

- "Connection refused" — Database isn't running or wrong port
- "Access denied" — Wrong credentials
- "Too many connections" — Database overwhelmed

---

## Checking External Connectivity

**The ask:** "Can the server reach [external service]?"

### Basic Connectivity Test

``` bash title="Ping External Host"
ping -c 4 google.com
ping -c 4 api.example.com
```

### Test HTTP Endpoints

``` bash title="Test HTTP Connection"
curl -I https://api.example.com/health
```

**What to look for:**

- `HTTP/1.1 200 OK` — It's working
- `Connection refused` — Service is down or blocked
- `Connection timed out` — Network issue or firewall

### Check DNS Resolution

``` bash title="Verify DNS Works"
nslookup api.example.com
# or
dig api.example.com
```

### Test Specific Port

``` bash title="Test Port Connectivity"
nc -zv api.example.com 443
# Connection to api.example.com 443 port [tcp/https] succeeded!
```

---

## Checking Recent Deployments

**The ask:** "When was the last deploy? What changed?"

### Check Git History

``` bash title="Recent Git Commits"
cd /var/www/app
git log --oneline -10
```

``` bash title="What Changed Recently"
git log --since="24 hours ago" --oneline
```

### Check File Modification Times

``` bash title="Recently Modified Files"
find /var/www/app -type f -mtime -1 | head -20
```

### Check Deployment Logs

``` bash title="Deployment Logs"
ls -la /var/log/deploy/
tail -100 /var/log/deploy/deploy.log
```

---

## Verifying a Fix Worked

**The ask:** "Can you verify the fix worked?"

### Check Service Status

``` bash title="Verify Service Running"
systemctl status nginx
```

### Check Logs for Errors

``` bash title="Check for New Errors"
tail -f /var/log/nginx/error.log
```

Wait a minute, trigger some traffic, see if errors appear.

### Test the Endpoint

``` bash title="Test Application"
curl -s http://localhost/health | head -20
curl -I https://app.example.com/api/status
```

### Monitor for a Few Minutes

``` bash title="Watch Logs After Fix"
journalctl -u nginx -f
```

Watch for a few minutes. No errors? The fix probably worked.

---

## Task Quick Reference

| Task | Command |
|------|---------|
| Check if service running | `systemctl status servicename` |
| Check listening ports | `ss -tlnp` or `netstat -tlnp` |
| Follow logs | `tail -f /var/log/app/error.log` |
| Find errors in logs | `grep -i error /var/log/app/*.log` |
| Check config file | `cat /etc/nginx/nginx.conf` |
| Find config setting | `grep -r "setting" /etc/nginx/` |
| Check CPU/memory | `top` or `htop` |
| Check disk space | `df -h` |
| Find large files | `du -sh /* \| sort -hr \| head` |
| Test connectivity | `ping`, `curl`, `nc -zv` |
| Recent deployments | `git log --oneline -10` |

---

## Practice Exercises

??? question "Exercise 1: Check Whether a Service Is Healthy"
    Your team lead asks: "Is nginx running and actually accepting connections?" Check the service status AND verify it's listening on port 80.

    **Hint:** You need two commands — `systemctl` and `ss`.

??? tip "Solution"
    ```bash title="Check nginx Status and Port"
    systemctl status nginx
    ss -tlnp | grep :80
    ```

    You want to see `Active: active (running)` from the first command, and a `LISTEN` entry on port 80 from the second. If the service is running but not listening, something is wrong with its configuration.

??? question "Exercise 2: Find What's Eating Disk Space"
    `df -h` shows that `/var` is at 91% usage. Find the top 10 largest directories inside `/var`.

    **Hint:** Use `du` with appropriate flags, then sort.

??? tip "Solution"
    ```bash title="Find Large Directories in /var"
    du -sh /var/* 2>/dev/null | sort -hr | head -10
    ```

    `/var/log` is the usual culprit on busy servers. From there, drill deeper:
    ```bash title="Drill Into /var/log"
    du -sh /var/log/* 2>/dev/null | sort -hr | head -10
    ```

??? question "Exercise 3: Verify a Fix Worked"
    After a colleague restarts a service, you're asked to confirm it's working. What's your verification process for nginx?

    **Hint:** Three steps — service status, port listening, no new errors in logs.

??? tip "Solution"
    ```bash title="Full nginx Health Check"
    # 1. Service is running
    systemctl status nginx

    # 2. Listening on expected ports
    ss -tlnp | grep nginx

    # 3. No new errors in last 50 lines
    tail -50 /var/log/nginx/error.log
    ```

    Watch the logs for 30–60 seconds after the restart. A clean log with no new errors is a good sign.

## Quick Recap

**Service checks:**

1. `systemctl status` — Is it running?
2. `ss -tlnp` — Is it listening?
3. `tail -f` logs — Any errors?

**Resource checks:**

1. `top` — CPU/memory overview
2. `df -h` — Disk space
3. `du -sh` — What's using space

**Connectivity checks:**

1. `ping` — Basic reachability
2. `curl` — HTTP endpoints
3. `nc -zv` — Port connectivity

---

## Further Reading

### Command References

- `man systemctl` — Full systemctl documentation including all unit states and sub-commands
- `man ss` — Socket statistics; replaces the deprecated `netstat` on modern systems
- `man top` — Interactive process viewer; press `h` inside `top` for a keyboard shortcut reference
- `man df` — Disk free space; `-i` shows inode usage (a different way a filesystem can "fill up")
- `man du` — Disk usage; `--max-depth` controls how many levels deep to report
- `man curl` — HTTP client with extensive options for testing endpoints and APIs

### Official Documentation

- [systemd documentation](https://systemd.io/) — Comprehensive systemd and systemctl reference
- [Red Hat: Managing Services with systemd](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/configuring_basic_system_settings/managing-services-with-systemd_configuring-basic-system-settings) — Practical systemd service management guide

### Related Articles

- [Reading Logs](reading_logs.md) — In-depth guide to log analysis; covers everything in the Tailing Logs section above and much more
- [Safe Exploration](safe_exploration.md) — Reminder of which commands are safe to run on production without permission

## What's Next?

You've learned what to do. Now let's cover what NOT to do. Head to [The "Don't Do This" Guide](safety_guide.md) for production safety rules that will keep you out of trouble.

!!! tip "Write Down Your Findings"
    When someone asks you to check something, report back with specifics:

    > "Nginx is running (PID 1234, up for 5 days). It's listening on port 80 and 443. The last error in the logs was 2 hours ago and looks like a client timeout, not a server issue."

    Much better than "Yeah, it's fine."
