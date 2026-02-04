# Reading Logs Like a Pro

Something broke. The app is throwing errors. Users are complaining. Your team lead says, "Can you check the logs?"

And now you're staring at files full of timestamps and cryptic messages wondering where to even begin.

**Let's fix that.**

Reading logs is probably the most important skill for debugging production systems. Once you get comfortable with it, you'll be able to diagnose problems in minutes instead of hours.

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

## The Essential Log Commands

### tail - View the End of a Log

Most recent entries are at the bottom. Start there:

``` bash title="Last 20 Lines"
tail -20 /var/log/syslog
```

``` bash title="Last 100 Lines"
tail -100 /var/log/nginx/error.log
```

### tail -f - Watch Logs in Real-Time

This is the killer feature. Watch new log entries appear as they're written:

``` bash title="Follow Log in Real-Time"
tail -f /var/log/nginx/access.log
```

Now trigger the problem (refresh the page, make an API call) and watch the log entries appear live.

Press `Ctrl+C` to stop following.

**Follow multiple logs at once:**

``` bash title="Follow Multiple Logs"
tail -f /var/log/nginx/access.log /var/log/nginx/error.log
```

### head - View the Beginning of a Log

Sometimes you need to see when a log started:

``` bash title="First 20 Lines"
head -20 /var/log/syslog
```

### less - Browse Large Logs

For navigating through huge log files:

``` bash title="Browse Log File"
less /var/log/syslog
```

**Useful `less` commands:**

| Key | Action |
|-----|--------|
| `G` | Jump to end (most recent) |
| `g` | Jump to beginning |
| `/error` | Search for "error" |
| `n` | Next search match |
| `N` | Previous search match |
| `q` | Quit |

---

## Searching Logs with grep

### Find All Errors

``` bash title="Find Error Lines"
grep -i "error" /var/log/syslog
```

The `-i` makes it case-insensitive (catches "Error", "ERROR", "error").

### Find Errors with Context

What happened before and after the error?

``` bash title="Show Context Around Errors"
grep -i -B 3 -A 3 "error" /var/log/nginx/error.log
```

- `-B 3` — Show 3 lines **B**efore the match
- `-A 3` — Show 3 lines **A**fter the match

### Find by Timestamp

Logs usually start with timestamps. Search for a specific time:

``` bash title="Find Entries from Specific Time"
grep "Jan 15 14:" /var/log/syslog
```

This finds all entries from 2pm on January 15th.

### Combine grep with tail

See recent errors only:

``` bash title="Recent Errors Only"
tail -500 /var/log/nginx/error.log | grep -i "error"
```

### Count Occurrences

How many times did this error happen?

``` bash title="Count Error Occurrences"
grep -c "connection refused" /var/log/syslog
# 47
```

47 connection refused errors. That's probably significant.

---

## journalctl - The Modern Log Tool

On systems using systemd (most modern Linux), `journalctl` is incredibly powerful:

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

## Reading Common Log Formats

### Nginx Access Logs

```
192.168.1.50 - - [15/Jan/2024:14:23:45 +0000] "GET /api/users HTTP/1.1" 200 1234 "-" "Mozilla/5.0..."
```

| Part | Meaning |
|------|---------|
| `192.168.1.50` | Client IP |
| `[15/Jan/2024:14:23:45 +0000]` | Timestamp |
| `"GET /api/users HTTP/1.1"` | Request |
| `200` | HTTP status code |
| `1234` | Response size (bytes) |

**Look for:**

- `4xx` codes — Client errors (404 not found, 401 unauthorized)
- `5xx` codes — Server errors (500 internal error, 502 bad gateway)

``` bash title="Find 500 Errors"
grep '" 500 ' /var/log/nginx/access.log
```

### Nginx Error Logs

```
2024/01/15 14:23:45 [error] 1234#0: *5678 connect() failed (111: Connection refused) while connecting to upstream
```

These are more descriptive. The `[error]` level and message tell you what went wrong.

### Syslog Format

```
Jan 15 14:23:45 prod-web-01 nginx[1234]: 2024/01/15 14:23:45 [error] ...
```

| Part | Meaning |
|------|---------|
| `Jan 15 14:23:45` | Timestamp |
| `prod-web-01` | Hostname |
| `nginx[1234]` | Service name and PID |
| Everything after `:` | The actual message |

---

## Log Analysis Patterns

### "Something Broke at 2:30pm"

Find what happened around that time:

``` bash title="Investigate Time Window"
journalctl --since "14:25" --until "14:35"
# or
grep "14:3" /var/log/syslog | less
```

### "The App Keeps Crashing"

Look for patterns in errors:

``` bash title="Find Unique Error Messages"
grep -i "error" /var/log/app/error.log | sort | uniq -c | sort -rn | head -20
```

This shows you the most common errors, sorted by frequency.

### "When Did This Start?"

Find the first occurrence:

``` bash title="First Occurrence of Error"
grep -m 1 "connection refused" /var/log/syslog
```

The `-m 1` stops after the first match.

### "Is It Still Happening?"

Watch for new occurrences:

``` bash title="Watch for Specific Error"
tail -f /var/log/syslog | grep --line-buffered "error"
```

The `--line-buffered` ensures you see matches immediately.

---

## Accessing Protected Logs

Some logs require elevated access:

``` bash title="View Protected Logs with Sudo"
sudo tail -100 /var/log/secure
sudo journalctl -u sshd
```

Or if you're in the `adm` group, you might already have read access to most logs.

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

## What's Next?

You can read logs like a pro. But where do you find documentation about this specific server and its applications? Head to [Finding Documentation](finding_docs.md) to learn how to find team wikis, runbooks, and who to ask for help.

!!! tip "Logs Tell Stories"
    Every log entry is a breadcrumb. Errors rarely happen in isolation — there's usually a chain of events. Learn to read that story, and debugging becomes much easier.
