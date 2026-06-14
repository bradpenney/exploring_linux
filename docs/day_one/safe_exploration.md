---
date: "2025-11-21 16:34"
title: Safe Exploration of a Linux Server
description: Explore a Linux server without breaking anything. Learn which commands are safe, how to navigate the filesystem confidently, and what to avoid in production.
---

# Safe Exploration

!!! tip "Part of Day One"
    This is the fourth article in the [Day One: Getting Started](overview.md) series. You should have already completed [Getting Access](getting_access.md), [Orientation](orientation.md), and [Understanding Your Permissions](permissions.md).

You're [logged in](getting_access.md), you've [oriented yourself](orientation.md), and you [understand your permission level](permissions.md). Now you want to poke around — see what's on this server, find the application code, locate config files.

But there's a voice in your head: *"What if I break something?"*

**Good instinct. Let's explore without touching anything.**

This article is about read-only reconnaissance. Looking without modifying. Finding things without moving them. By the end, you'll be able to confidently explore any server knowing you're not going to accidentally bring down production.

## The Exploration Workflow

Here's your path to safely exploring a server:

``` mermaid
graph TD
    A[Start: You're Logged In] --> B[List Directories<br/>ls, tree]
    B --> C[Read Files<br/>cat, less, head, tail]
    C --> D[Follow Logs<br/>tail -f]
    D --> E[Understand Server<br/>Confident & Safe]

    style A fill:#1a202c,stroke:#cbd5e0,stroke-width:2px,color:#fff
    style B fill:#2d3748,stroke:#cbd5e0,stroke-width:2px,color:#fff
    style C fill:#2d3748,stroke:#cbd5e0,stroke-width:2px,color:#fff
    style D fill:#2d3748,stroke:#cbd5e0,stroke-width:2px,color:#fff
    style E fill:#d69e2e,stroke:#cbd5e0,stroke-width:2px,color:#000
```

---

## The Golden Rule: Read, Don't Write

=== ":material-check-circle: Safe Commands (Read-Only)"

    These commands **only read data** - use them freely:

    | Command | What It Does | Safety Level |
    |---------|-------------|--------------|
    | `ls` | List files and directories | ✅ Completely safe |
    | `tree` | Show directory structure | ✅ Completely safe |
    | `cat`, `less` | View file contents | ✅ Completely safe |
    | `head`, `tail` | View beginning/end of files | ✅ Completely safe |
    | `pwd`, `cd` | Check/change location | ✅ Completely safe |
    | `whoami`, `id` | Check your identity | ✅ Completely safe |

=== ":material-alert: Dangerous Commands (Modify Data)"

    These commands **change things** - avoid during exploration:

    | Command | What It Does | Why It's Dangerous |
    |---------|-------------|-------------------|
    | `rm` | Delete files | ⚠️ Cannot be undone |
    | `mv` | Move/rename files | ⚠️ Can overwrite files |
    | `cp` | Copy files | ⚠️ Creates new files, uses disk space |
    | `chmod`, `chown` | Change permissions | ⚠️ Can break access control |
    | `systemctl restart/stop` | Modify services | 🚨 Can disrupt service |
    | `vim`, `nano` | Open editor | ⚠️ Might accidentally save changes |
    | `>` or `>>` | Redirect output to file | ⚠️ Can overwrite or create files |
    | `sudo` anything | Run as root | 🚨 Maximum impact if wrong |

---

## Exploring Directories

### Look Before You Leap

Before diving into a directory, peek at what's there:

``` bash title="List Directory Contents" linenums="1"
ls -la /var/log/
```

The `-la` flags give you the full picture:

- `-l` — Long format (permissions, owner, size, date)
- `-a` — Show hidden files (starting with `.`)

### What Those Columns Mean

We covered permissions in detail in [Understanding Your Permissions](permissions.md), but here's what you're seeing when you explore with `ls -la`:

```
drwxr-xr-x 2 root root 4096 Jan 15 10:30 nginx
│          │ │    │    │    │            └─── Filename
│          │ │    │    │    └────────────────── Last modified (when changed)
│          │ │    │    └─────────────────────── Size in bytes
│          │ │    └──────────────────────────── Group
│          │ └─────────────────────────────────── Owner
│          └──────────────────────────────────────  Link count
└─────────────────────────────────────────────────  Permissions (d=dir, -=file, see previous article for rwx details)
```

**For exploration, focus on:** filename, size, and last modified date. These tell you what's here, how big it is, and how recent it is.

### Explore Directory Trees

See the structure without opening files:

``` bash title="Show Directory Tree" linenums="1"
tree /var/www/ -L 2  # (1)!
```

1. `-L 2` limits the output to 2 levels deep. Without a depth limit, `tree` recurses through every subdirectory — on a large application directory, this can dump thousands of lines.

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

??? tip "tree Not Installed?"
    Some minimal servers don't have `tree`. Use this alternative:

    ``` bash title="Tree Alternative" linenums="1"
    find /var/www -maxdepth 2 -type d
    ```

---

## Reading Files Safely

### Quick Peek at Small Files

``` bash title="View Entire File" linenums="1"
cat /etc/hostname
# prod-web-01
```

Good for small files. Bad for large files (it dumps everything to your terminal).

### Browse Large Files

For anything more than a few lines, use `less`:

``` bash title="Browse with less" linenums="1"
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

Often you don't need to see the entire file—just the start to check format, or the end to see recent activity.

=== ":material-arrow-up-bold: Beginning (`head`)"

    **When to use this:**

    - Check file format or headers (CSV files, config files)
    - See the shebang line in scripts (`#!/bin/bash`)
    - Preview what a file contains without opening it all
    - Check documentation structure (README files, man pages)

    ``` bash title="First 20 Lines" linenums="1"
    head -n 20 /var/log/nginx/access.log
    ```

    ``` bash title="First 10 Lines (default)" linenums="1"
    head /etc/hosts
    ```

=== ":material-arrow-down-bold: End (`tail`)"

    **When to use this:**

    - **Most common:** View recent log entries (logs append to the end)
    - See the latest errors or activity
    - Check if a process recently wrote to a file
    - Find the current state vs historical data

    ``` bash title="Last 20 Lines" linenums="1"
    tail -n 20 /var/log/nginx/access.log
    ```

    ``` bash title="Last 50 Lines" linenums="1"
    tail -n 50 /var/log/nginx/error.log
    ```

    ``` bash title="Last 10 Lines (default)" linenums="1"
    tail /var/log/syslog
    ```

=== ":material-arrow-expand-vertical: Headers + Recent"

    !!! tip "Advanced Pattern - Don't Worry About Memorizing This"
        This is a handy trick once you're comfortable with `head` and `tail`. For Day One, just knowing the basic commands is enough!

    **When to use this:**

    - See column headers plus the most recent entries (filesystem usage, process lists)
    - Check table structure and latest data without scrolling through everything
    - Common pattern: "Show me what the columns mean and the last few entries"

    ``` bash title="Filesystem Headers + Last 3 Mounts" linenums="1"
    df -h | { head -n 1; tail -n 3; }  # (1)!
    # Filesystem      Size  Used Avail Use% Mounted on
    # /dev/sda5       100G   45G   50G  48% /data
    # /dev/sdb1       500G  320G  180G  64% /backups
    # tmpfs           7.8G     0  7.8G   0% /run/user/1000
    ```

    1. `{ ; }` groups commands that both read from the same pipe. `head -n 1` consumes the header line; `tail -n 3` consumes the last 3 lines. Without the braces, you'd need to run `df -h` twice.

    **What you see:** The header row explaining the columns, then just the last 3 filesystem mounts—skipping everything in between.

    ``` bash title="Process List Headers + Last 5 Processes" linenums="1"
    ps aux | { head -n 1; tail -n 5; }
    ```

    ``` bash title="How It Works" linenums="1"
    # The { } groups commands together
    # head -n 1 shows the header row
    # tail -n 3 shows the last 3 lines
    # Together: header + recent entries
    ```

    **Pro tip:** This pattern works great with any command that outputs tables with headers.

### Follow a File in Real-Time

This is incredibly useful for watching logs as they're being written:

**Using `tail -f` (most common):**

``` bash title="Watch Log Updates Live" linenums="1"
tail -f /var/log/nginx/access.log
```

New lines appear as they're written. Press `Ctrl+C` to stop.

**Using `less` + `F` key:**

If you're already viewing a file in `less`, press `F` to enter follow mode (same as `tail -f`). Press `Ctrl+C` to stop following and return to normal `less` navigation.

``` bash title="View File, Then Follow" linenums="1"
less /var/log/nginx/access.log
# Press F to start following
# Press Ctrl+C to stop following
# Press q to quit less
```

**When to use which:**

- Use `tail -f` when you know you want to follow from the start
- Use `less` + `F` when you're browsing a file and decide you want to follow it

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

## Common Day One Exploration Tasks

=== ":material-folder-open: What's in This Directory?"

    ``` bash title="List Everything with Details" linenums="1"
    ls -la
    ```

    **Look for:**

    - Files and directories (first column: `-` = file, `d` = directory)
    - File sizes (helpful to know before opening)
    - Last modified dates (when was this last touched?)

=== ":material-file-document-multiple: Where Are the Logs?"

    Logs are almost always in `/var/log/`:

    ``` bash title="Explore Log Directory" linenums="1"
    ls -la /var/log/
    ```

    **Common log files you'll see:**

    - `syslog` - System messages
    - `auth.log` - Authentication attempts
    - `kern.log` - Kernel messages
    - Application-specific directories (nginx/, apache2/, etc.)

=== ":material-file-eye: What's in This File?"

    **Quick peek at a file:**

    ``` bash title="View a Small File" linenums="1"
    cat /etc/hostname
    ```

    **Browse a larger file:**

    ``` bash title="Browse with less" linenums="1"
    less /var/log/syslog
    ```

    **See just the end (for logs):**

    ``` bash title="Last 20 Lines" linenums="1"
    tail -n 20 /var/log/syslog
    ```

---

## Practice Problems

Now that you know how to explore safely, try these hands-on exercises:

??? question "Problem 1: Explore a Directory"
    Navigate to `/var/log` and explore its structure without opening any files.

    1. List all files and directories with details
    2. Notice the file sizes and dates
    3. Try using `tree` if available

    **Hint:** Use `ls -la` and optionally `tree`.

    ??? tip "Answer"
        ``` bash title="Explore /var/log" linenums="1"
        # List everything with details
        ls -la /var/log

        # Show directory tree (if tree is installed)
        tree /var/log -L 2
        ```

        **What to notice:**
        - Directory vs file (first column: `d` = directory, `-` = file)
        - File sizes (some logs can be very large)
        - Last modified dates (when was this last touched?)
        - Ownership (most owned by root or specific service accounts)

??? question "Problem 2: Read a Log File"
    Look at the system log to see what's been happening on the server.

    1. View the last 20 lines of `/var/log/syslog` (or `/var/log/messages` on some systems)
    2. Follow the log in real-time for a few seconds

    **Hint:** Use `tail` with `-n 20` and `-f` flags.

    ??? tip "Answer"
        ``` bash title="View Recent System Logs" linenums="1"
        # See the last 20 lines
        tail -n 20 /var/log/syslog

        # Follow in real-time (press Ctrl+C to stop)
        tail -f /var/log/syslog
        ```

        **What to notice:**
        - Timestamps on each log line
        - Service names (what's generating these messages)
        - Different message types (info, warning, error)

??? question "Problem 3: Explore Your Home Directory"
    Get familiar with where your personal files live.

    1. List all files in your home directory (including hidden files)
    2. Look at the structure with `tree` if available
    3. Use `less` to browse your `.bashrc` or `.profile` file

    **Hint:** Use `cd ~` to go home, then `ls -la` to list everything.

    ??? tip "Answer"
        ``` bash title="Explore Your Home" linenums="1"
        # Go to your home directory
        cd ~

        # List everything including hidden files
        ls -la

        # View directory tree
        tree -L 1

        # Browse your bash config (read-only, safe)
        less .bashrc
        ```

        **What to notice:**
        - Hidden files start with `.` (like `.bashrc`, `.profile`)
        - Your home directory is your personal workspace
        - Config files here customize your terminal experience

---

## Day One Exploration Cheat Sheet

Now that you've learned the commands, here's a quick reference for common Day One tasks:

| Task | Safe Commands | What to Look For | Avoid |
|------|---------------|------------------|-------|
| **Explore a directory** | `ls -la`<br/>`tree -L 2` | File sizes, dates, permissions | `rm`, `mv` - Don't delete or move |
| **Find logs** | `ls -la /var/log/` | syslog, auth.log, app directories | Don't modify or delete logs |
| **Read a file** | `cat filename`<br/>`less filename`<br/>`head -n 20 filename`<br/>`tail -n 20 filename` | File contents, structure, recent entries | `vim`, `nano` - Don't edit accidentally |
| **Follow logs live** | `tail -f /var/log/syslog`<br/>`less` then press `F` | Real-time updates, errors as they happen | `>`, `>>` - Don't redirect to files |
| **When unsure** | Use `command --help` | Command documentation | Never run with `sudo` unless certain |

**Golden rule:** If you're just looking, you're safe. If you're changing, stop and think.

---

## Quick Recap

**The golden rule:** Read-only commands can't break things. Stay in that lane during Day One.

- **Navigate:** `ls -la` to list, `tree -L 2` for structure
- **Read files:** `cat` for small files, `less` for large ones, `head`/`tail` for beginning or end
- **Watch live:** `tail -f` to follow a log as it's written
- **Before you open:** Run `ls -la filename` first — file size tells you whether `cat` is safe or whether you need `less`

See the [cheat sheet above](#day-one-exploration-cheat-sheet) for a full command reference.

---

## Further Reading

### Command References

- `man ls` - List directory contents with all options
- `man less` - View file contents interactively
- `man cat` - Display file contents
- `man head` - Output the first part of files
- `man tail` - Output the last part of files
- `man tree` - Display directory trees

### Deep Dives

- [Explain Shell](https://explainshell.com/) - Visual breakdown of shell commands
- [TLDR Pages](https://tldr.sh/) - Simplified command examples
- [Linux Journey: Command Line](https://linuxjourney.com/lesson/the-shell) - Interactive learning path
- [OverTheWire: Bandit](https://overthewire.org/wargames/bandit/) - Security wargame for learning Linux commands safely in a controlled environment

### Official Documentation

- [GNU Coreutils Manual](https://www.gnu.org/software/coreutils/manual/) - Official docs for `ls`, `cat`, `head`, `tail`, etc.

---

## What's Next?

Now that you can explore safely, head to **[Reading Logs Like a Pro](reading_logs.md)** — learning to read logs is the most powerful skill you'll develop for diagnosing problems on production systems.
