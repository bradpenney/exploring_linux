# Advanced Content Removed from Day One Safe Exploration

This content is too advanced for Day One. Move to Level 1 article on "Finding and Filtering."

---

## Finding Files

!!! danger "⚠️ Here Be Dragons: find + xargs Can Be Destructive"
    The `find` commands shown below are **read-only and safe**. However, `find` is often combined with `-exec` or piped to `xargs` to perform actions on files—and these can be **extremely destructive**.

    **NEVER copy-paste `find` commands from the internet without fully understanding them.**

    Dangerous examples you might see online:

    - `find . -name "*.tmp" -exec rm {} \;` — Deletes all .tmp files
    - `find / -type f -size +100M -delete` — Deletes all large files
    - `find . -name "*.log" | xargs rm` — Deletes all log files

    **Safe exploration rule:** Only use `find` for searching (like the examples below). Don't add `-exec`, `-delete`, or pipe to `xargs` until you fully understand what you're doing.

### Find by Name

``` bash title="Find Files Named config"
find /etc -name "*.conf" 2>/dev/null | head -20
```

The `2>/dev/null` hides "permission denied" errors for directories you can't access.

### Find Recently Modified Files

What changed in the last day?

``` bash title="Files Modified in Last 24 Hours"
find /var/www -mtime -1 -type f 2>/dev/null
```

What changed in the last hour?

``` bash title="Files Modified in Last Hour"
find /var/log -mmin -60 -type f 2>/dev/null
```

### Find Large Files

What's eating up disk space?

``` bash title="Find Files Over 100MB"
find / -type f -size +100M 2>/dev/null
```

---

## Searching Inside Files

### Search for Text

``` bash title="Find Error Messages"
grep "error" /var/log/syslog
```

Case-insensitive search:

``` bash title="Case-Insensitive Search"
grep -i "error" /var/log/syslog
```

### Search with Context

Show lines before and after the match:

``` bash title="Show Surrounding Lines"
grep -B 2 -A 2 "error" /var/log/syslog
```

`-B 2` shows 2 lines before, `-A 2` shows 2 lines after.

### Search Recursively

Search all files in a directory:

``` bash title="Search All Files in Directory"
grep -r "database" /etc/nginx/ 2>/dev/null
```

### Find Which Files Contain a String

Just list the filenames, not the matching lines:

``` bash title="List Files Containing String"
grep -l "password" /etc/*.conf 2>/dev/null
```

!!! warning "Be Careful What You Search For"
    Searching for "password" might show you credentials. If you find any, **don't screenshot, copy, or share them**. Report to your security team if you find exposed secrets.

---

## Exploring Running Processes

### What's Running Right Now?

``` bash title="List All Processes"
ps aux
```

There's a lot of output. Filter to what matters:

``` bash title="Find Specific Process"
ps aux | grep nginx
```

``` bash title="Find Java Processes"
ps aux | grep java
```

### Interactive Process Viewer

``` bash title="Live Process Monitor"
top
```

**Useful `top` shortcuts:**

| Key | Action |
|-----|--------|
| `M` | Sort by memory usage |
| `P` | Sort by CPU usage |
| `k` | Kill a process (careful!) |
| `q` | Quit |

For a friendlier interface (if installed):

``` bash title="Better Process Viewer"
htop
```

### Find What's Listening on Ports

``` bash title="Show Listening Ports"
netstat -tlnp 2>/dev/null
# or
ss -tlnp
```

```
State    Local Address:Port    Process
LISTEN   0.0.0.0:80            nginx
LISTEN   0.0.0.0:443           nginx
LISTEN   127.0.0.1:3306        mysqld
```

This tells you what services are running and what ports they use.

---

## Exploring Services

### List All Services

``` bash title="List Systemd Services"
systemctl list-units --type=service
```

### Check a Specific Service

``` bash title="Service Status (Safe)"
systemctl status nginx
```

This shows:

- Whether it's running
- Recent log output
- Process ID
- Memory usage

**This is read-only and completely safe.** It doesn't restart or modify anything.

---

## Advanced Exploration Workflows

### "Where's the Application Code?"

``` bash title="Find Web Application"
ls -la /var/www/
ls -la /opt/
ls -la /home/*/
find / -name "*.py" -o -name "*.js" -o -name "*.java" 2>/dev/null | head -30
```

### "What's This Server's Purpose?"

``` bash title="Identify Server Role"
systemctl list-units --type=service --state=running
netstat -tlnp 2>/dev/null
cat /etc/hostname
```

---

## Advanced Practice Exercises

??? question "Exercise 2: Find Recently Modified Files"
    Find all files in `/etc` that were modified in the last 7 days.

    **Hint:** Use `find` with the `-mtime` flag. Remember `2>/dev/null` to hide permission errors.

    ??? tip "Solution"
        ``` bash title="Find Recently Modified Config Files"
        find /etc -type f -mtime -7 2>/dev/null

        # With more details:
        find /etc -type f -mtime -7 -ls 2>/dev/null

        # Just count them:
        find /etc -type f -mtime -7 2>/dev/null | wc -l
        ```

        **What this shows:**
        - Configuration files that were recently changed
        - Potential recent system updates or modifications
        - Which config files are actively managed

??? question "Exercise 3: Search for a Service's Config"
    Imagine your server runs nginx. Find all nginx-related configuration files without knowing exactly where they are.

    **Hint:** Use `find` to search for files with "nginx" in the name, and `grep` to search inside config files.

    ??? tip "Solution"
        ``` bash title="Find Nginx Config Files"
        # Find files with nginx in the name
        find /etc -name "*nginx*" 2>/dev/null

        # Find config files mentioning nginx
        grep -r "nginx" /etc/*.conf 2>/dev/null

        # Check if nginx service exists
        systemctl status nginx 2>/dev/null

        # Find where nginx binary is located
        which nginx
        ```

        **Common locations you'll find:**
        - `/etc/nginx/` - Main config directory
        - `/etc/nginx/nginx.conf` - Primary config file
        - `/etc/nginx/sites-available/` - Site configs
        - `/var/log/nginx/` - Log files

??? question "Exercise 4: Safely Check a Running Service"
    Check if nginx is running and view its recent logs WITHOUT modifying anything.

    **Challenge:** Can you find what port it's listening on?

    ??? tip "Solution"
        ``` bash title="Safely Check Nginx Status"
        # Check if service is running
        systemctl status nginx

        # View recent logs
        journalctl -u nginx -n 20

        # Or check traditional log files
        tail -20 /var/log/nginx/access.log

        # Find what ports it's listening on
        netstat -tlnp 2>/dev/null | grep nginx
        # or
        ss -tlnp | grep nginx
        ```

        **What you learned:**
        - Service status (active/inactive)
        - Process ID and memory usage
        - Recent log entries
        - Which ports the service uses
