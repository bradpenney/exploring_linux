# Safe Exploration

You're logged in, you've oriented yourself, and you understand your permission level. Now you want to poke around — see what's on this server, find the application code, locate config files.

But there's a voice in your head: *"What if I break something?"*

**Good instinct. Let's explore without touching anything.**

This article is about read-only reconnaissance. Looking without modifying. Finding things without moving them. By the end, you'll be able to confidently explore any server knowing you're not going to accidentally bring down production.

---

## The Golden Rule: Read, Don't Write

These commands are **safe** — they only read data:

- `ls` — List files
- `cat`, `less`, `head`, `tail` — View file contents
- `find` — Search for files
- `grep` — Search inside files
- `ps`, `top` — View processes
- `df`, `du` — Check disk usage
- `pwd`, `whoami`, `id` — Check your context

These commands **modify things** — avoid until you know what you're doing:

- `rm` — Delete files
- `mv` — Move/rename files
- `cp` — Copy files (generally safe, but creates new files)
- `chmod`, `chown` — Change permissions
- `systemctl restart/stop` — Modify services
- `vim`, `nano` — Open editor (might accidentally save changes)
- Any command with `>` or `>>` — Redirects output to files

---

## Exploring Directories

### Look Before You Leap

Before diving into a directory, peek at what's there:

``` bash title="List Directory Contents"
ls -la /var/log/
```

The `-la` flags give you the full picture:

- `-l` — Long format (permissions, owner, size, date)
- `-a` — Show hidden files (starting with `.`)

### What Those Columns Mean

```
drwxr-xr-x 2 root root 4096 Jan 15 10:30 nginx
-rw-r----- 1 root adm  52428 Jan 15 14:22 syslog
```

| Column | Meaning |
|--------|---------|
| `d` or `-` | Directory or file |
| `rwxr-xr-x` | Permissions (owner/group/others) |
| `root root` | Owner and group |
| `4096` | Size in bytes |
| `Jan 15 10:30` | Last modified |
| `nginx` | Name |

### Explore Directory Trees

See the structure without opening files:

``` bash title="Show Directory Tree"
tree /var/www/ -L 2
```

```
/var/www/
├── html
│   ├── index.html
│   └── assets
└── app
    ├── config
    └── logs
```

The `-L 2` limits depth to 2 levels (so you don't dump thousands of files).

!!! tip "tree Not Installed?"
    Some minimal servers don't have `tree`. Use this alternative:

    ``` bash title="Tree Alternative"
    find /var/www -maxdepth 2 -type d
    ```

---

## Reading Files Safely

### Quick Peek at Small Files

``` bash title="View Entire File"
cat /etc/hostname
# prod-web-01
```

Good for small files. Bad for large files (it dumps everything to your terminal).

### Browse Large Files

For anything more than a few lines, use `less`:

``` bash title="Browse with less"
less /var/log/syslog
```

**Navigation in `less`:**

| Key | Action |
|-----|--------|
| `Space` | Page down |
| `b` | Page up |
| `g` | Go to beginning |
| `G` | Go to end |
| `/pattern` | Search forward |
| `n` | Next search match |
| `q` | Quit |

### View Just the Beginning or End

``` bash title="First 20 Lines"
head -20 /var/log/nginx/access.log
```

``` bash title="Last 20 Lines"
tail -20 /var/log/nginx/access.log
```

``` bash title="Last 50 Lines"
tail -50 /var/log/nginx/error.log
```

### Follow a File in Real-Time

This is incredibly useful for watching logs:

``` bash title="Watch Log Updates Live"
tail -f /var/log/nginx/access.log
```

New lines appear as they're written. Press `Ctrl+C` to stop.

---

## Finding Files

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

## Safe Exploration Checklist

Before running any command, ask yourself:

| Question | If Yes... |
|----------|-----------|
| Does this command have `rm`, `mv`, or `>` in it? | Stop. Review carefully. |
| Does this require `sudo`? | Double-check you need it. |
| Am I opening an editor (`vim`, `nano`)? | Be careful not to save accidentally. |
| Does this command modify a service? | Don't run it during exploration. |
| Am I just reading/viewing data? | You're probably fine! |

---

## Common Exploration Workflows

### "Where's the Application Code?"

``` bash title="Find Web Application"
ls -la /var/www/
ls -la /opt/
ls -la /home/*/
find / -name "*.py" -o -name "*.js" -o -name "*.java" 2>/dev/null | head -30
```

### "Where Are the Logs?"

``` bash title="Find Log Directories"
ls -la /var/log/
find /var/log -name "*.log" -type f 2>/dev/null
```

### "What Config Files Exist?"

``` bash title="Explore Config Files"
ls -la /etc/
find /etc -name "*.conf" 2>/dev/null | head -30
```

### "What's This Server's Purpose?"

``` bash title="Identify Server Role"
systemctl list-units --type=service --state=running
netstat -tlnp 2>/dev/null
cat /etc/hostname
```

---

## Quick Recap

**Safe commands (read-only):**

- `ls`, `cat`, `less`, `head`, `tail`
- `find`, `grep`
- `ps`, `top`, `htop`
- `systemctl status`
- `df`, `du`

**Dangerous commands (modify data):**

- `rm`, `mv`, `chmod`, `chown`
- `systemctl restart/stop/start`
- Anything with `>`, `>>`, or `sudo` (unless you're sure)

**When in doubt:**

- Don't run it
- Ask someone
- Use `--help` to understand what a command does first

---

## What's Next?

You can explore safely. Now let's get really good at one of the most important exploration skills: reading logs. Head to [Reading Logs Like a Pro](reading_logs.md) to master `tail`, `journalctl`, and log analysis.

!!! tip "Practice Makes Permanent"
    The more you explore Linux servers, the more comfortable you'll become. These read-only commands can't hurt anything — use them liberally to build familiarity.
