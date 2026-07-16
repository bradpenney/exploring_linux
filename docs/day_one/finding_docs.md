---
date: "2025-11-21 16:34"
title: Finding Documentation on a Linux Server
description: Find documentation on an unfamiliar Linux server — man pages, README files, package docs, git history, and what the server itself tells you.
---

# Finding Documentation

!!! tip "Part of Day One"
    This is the sixth article in the [Day One: Getting Started](overview.md) series. You should have already completed [Getting Access](getting_access.md), [Orientation](orientation.md), [Understanding Your Permissions](permissions.md), [Safe Exploration](safe_exploration.md), and [Reading Logs](reading_logs.md).

You've been handed access to a server running an application you've never seen before. You can see it's running. You can see config files in `/etc/`. You can see something deployed in `/opt/`. But you have no idea what it does, how it's structured, or what the team intended.

Before you ask anyone anything — the server itself will tell you most of what you need to know. Linux has extensive documentation built in, and application teams almost always leave breadcrumbs. You just need to know where to look.

---

## The Built-in Manual System

This is the first thing most developers overlook — Linux ships with comprehensive documentation for every installed command. It's always available, works offline, and covers the exact version of the software installed on this server.

### man — The Manual

``` bash title="Read the Manual" linenums="1"
man nginx
man systemctl
man find
```

When you run `man nginx`, you'll see something like this:

```
NGINX(8)                System Manager's Manual                NGINX(8)

NAME
       nginx - HTTP and reverse proxy server

SYNOPSIS
       nginx [-?hvVtTq] [-s signal] [-p prefix] [-e filename] [-c filename] [-g directives]

DESCRIPTION
       nginx (pronounced "engine x") is an HTTP and reverse proxy server...
```

**Navigating man pages:**

| Key | Action |
|-----|--------|
| `Space` | Page down |
| `b` | Page up |
| `/pattern` | Search forward |
| `n` | Next match |
| `N` | Previous match |
| `q` | Quit |

**Key insight:** Jump straight to the `OPTIONS` or `FILES` section by searching — press `/OPTIONS` then `n` to get there immediately instead of reading from the top.

### Man Page Sections — The Hidden Power

Man pages are organised into numbered sections. Most developers only ever use section 1 (commands), but section 5 is where the real value is on an unfamiliar server:

| Section | What It Contains |
|---------|-----------------|
| 1 | User commands (`man ls`, `man grep`) |
| 5 | **Config file formats** — this is what you want |
| 8 | System administration commands (`man nginx`) |

Without specifying a section, `man` gives you section 1. If you want to understand a config file format, ask for section 5 explicitly:

``` bash title="Read Config File Formats" linenums="1"
man 5 sshd_config     # (1)!
man 5 fstab           # (2)!
man 5 crontab         # (3)!
man 5 sudoers         # (4)!
man 5 nginx           # (5)!
```

1. The `5` is the manual section number — section 5 covers **file formats and conventions**. Without specifying it, `man sshd_config` may not find the page at all, since section 1 (commands) is the default.
2. Filesystem table format.
3. Cron job format.
4. sudo config format.
5. nginx config directives (if installed).

**Key insight:** When you find a config file you don't understand, `man 5 configfilename` is usually the fastest path to understanding every option in it.

??? tip "What if man 5 returns nothing?"
    Some packages don't install man pages (minimal installs, containers). If `man 5 nginx` returns "No manual entry," try:

    ``` bash title="Fallback When Man Page Isn't There"
    less /etc/nginx/nginx.conf   # (1)!

    find /usr/share/doc -name "*nginx*" -type d   # (2)!

    # Or look online — the app's own docs are usually more complete:
    # nginx: https://nginx.org/en/docs/
    ```

    1. Read the config file itself — it's often heavily commented.
    2. Check for docs bundled with the package.

    For production services, the vendor's official documentation is often better than the man page regardless.

### --help — Quick Reference

For a fast summary without opening a pager:

``` bash title="Quick Help" linenums="1"
nginx --help
systemctl --help
find --help
```

The output is compact — flags, a brief description, done. Good when you remember that a flag exists but not exactly how it works:

```
Usage: nginx [-?hvVtTq] [-s signal] [-c filename] [-g directives]

Options:
  -?,-h         : this help
  -v            : show version and exit
  -V            : show version and configure options then exit
  -t            : test configuration and exit
  -c filename   : set configuration file (default: /etc/nginx/nginx.conf)
  -s signal     : send signal to a master process: stop, quit, reopen, reload
```

**Key insight:** `--help` is faster than `man` for quick flag lookups. Use `man` when you need to understand *why* something works the way it does.

### info — Extended Documentation

Some GNU tools have more detailed documentation in `info` than in their man pages — particularly `bash`, `coreutils`, and `find`:

``` bash title="Extended Documentation" linenums="1"
info bash
info coreutils
info find
```

Press `q` to quit. If the man page for a tool feels thin, try `info` — the GNU project often puts the full reference there.

---

## What the Server Tells You About Itself

Before looking at any application-specific documentation, let the server tell you what it is.

### The Login Message

The MOTD (Message of the Day) is configured by whoever manages the server. On a well-maintained system it tells new users exactly what they need to know:

``` bash title="Read the Login Message" linenums="1"
cat /etc/motd
```

A useful MOTD might look like:

```
=========================================
  prod-web-01 — API Server (Production)
  Application: payments-api v2.4
  Owner: payments-team@company.com
  Runbook: https://wiki.internal/payments-api
  DO NOT restart services without a change ticket
=========================================
```

If it's empty or generic, that's information too — this server may be newer, or the team may not have set one up.

### What's Running Here

``` bash title="List Running Services" linenums="1"
systemctl list-units --type=service --state=running
```

The output tells you the server's purpose without reading a single document:

```
UNIT                     LOAD   ACTIVE SUB     DESCRIPTION
nginx.service            loaded active running A high performance web server
postgresql.service       loaded active running PostgreSQL Database Server
redis.service            loaded active running Advanced key-value store
payments-api.service     loaded active running Payments API Application

LOAD   = Reflects whether the unit definition was properly loaded.
ACTIVE = The high-level unit activation state.
```

This tells you: web server, database, cache, and a custom application. You now know roughly what this server does before reading a single config file.

### Read the Service File

Once you know a service name, `systemctl cat` shows you its full unit file — how it starts, what user it runs as, what environment it needs, and what it depends on:

``` bash title="Read a Service Unit File" linenums="1"
systemctl cat nginx
systemctl cat payments-api
```

A service file reveals a lot:

```
# /etc/systemd/system/payments-api.service
[Unit]
Description=Payments API Application
After=network.target postgresql.service
Requires=postgresql.service

[Service]
Type=simple
User=payments
WorkingDirectory=/opt/payments-api
ExecStart=/opt/payments-api/bin/payments-api --config /etc/payments-api/config.yml
EnvironmentFile=/etc/payments-api/environment
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

From this one file you've learned: the application binary is at `/opt/payments-api/bin/payments-api`, its config is at `/etc/payments-api/config.yml`, it runs as the `payments` user, it depends on PostgreSQL, and it will restart automatically if it crashes.

**Key insight:** `systemctl cat` is often the best single command for understanding how an application is actually deployed on a specific server, regardless of what the generic documentation says.

---

## Application Documentation

### README Files

Developers almost always include a README. These are the first place to look for application-level context — what it does, how to configure it, what it needs to run:

``` bash title="Find README Files" linenums="1"
find /var/www /opt /home -name "README*" 2>/dev/null  # (1)!
find /var/www /opt /home -name "*.md" -maxdepth 4 2>/dev/null | head -20
```

1. `2>/dev/null` discards error messages from directories you can't read. Without it, `find` prints a "Permission denied" line for every restricted directory — cluttering the output with noise before you see any results.

You might find:

```
/opt/payments-api/README.md
/opt/payments-api/docs/DEPLOYMENT.md
/opt/payments-api/docs/CONFIGURATION.md
/var/www/frontend/README.md
```

Read them with `less` so you can navigate and search:

``` bash title="Read a README" linenums="1"
less /opt/payments-api/README.md
```

### Deployment Scripts

Deployment scripts are documentation in executable form. They describe exactly how the application is built, configured, tested, and deployed — often in more practical detail than any prose document:

``` bash title="Find Deployment Scripts" linenums="1"
find /var /opt /home /usr/local -name "deploy*" -type f 2>/dev/null | head -20
find /var /opt /home /usr/local -name "*.sh" -path "*/scripts/*" 2>/dev/null | head -20
find /opt -name "Makefile" 2>/dev/null
```

Read them — don't run them:

``` bash title="Read Deployment Scripts" linenums="1"
cat /opt/payments-api/scripts/deploy.sh
less /opt/payments-api/Makefile
```

A deploy script will tell you: what commands start the application, what environment variables it requires, how to run database migrations, and what the rollback procedure is. This is the kind of tribal knowledge that's often nowhere else.

!!! warning "Scope Your Searches"
    Searching from `/` can take minutes on a busy server. Always scope searches to specific directories — `/var`, `/opt`, `/home`, `/usr/local`. Use `2>/dev/null` to suppress permission errors on directories you can't read.

---

## Package Documentation

Every package installed via the system package manager (`apt`, `dnf`, `yum`) ships with documentation installed alongside the software:

``` bash title="Explore Package Documentation" linenums="1"
ls /usr/share/doc/
ls /usr/share/doc/nginx/
cat /usr/share/doc/nginx/README
```

A package documentation directory typically contains:

```
/usr/share/doc/nginx/
├── README
├── README.Debian       ← Distribution-specific notes (important!)
├── changelog.gz
└── copyright
```

**Key insight:** The `README.Debian` (or `README.RHEL`, etc.) files are especially valuable — they document changes the distribution maintainers made to the upstream software, which explains why the server's behaviour might differ from the official documentation. If a config option isn't working as expected, this is often where you find out why.

---

## Git History on the Server

If application code is deployed as a git repository, the git history is a rich source of documentation. Every decision the team made, every bug they fixed, every configuration they changed — all recorded with context:

``` bash title="Find Git Repos on the Server" linenums="1"
find /var /opt /home -name ".git" -type d 2>/dev/null | head -10
```

Once you find a repository:

``` bash title="Understand Recent Changes" linenums="1"
cd /opt/payments-api
git log --oneline -20
```

```
a3f2c19 Fix connection pool exhaustion under load
b891de4 Increase PostgreSQL connection timeout to 30s
c7d4a11 Add retry logic for failed payment webhooks
d523ef2 Update config for new payment provider API endpoint
e094bc3 Emergency fix: revert webhook rate limiting (causing timeouts)
```

Five commits and you know this application has had connection pool issues, timeout problems, and an emergency rollback in its recent history. That's context you'd never get from a README.

``` bash title="Understand a Specific File" linenums="1"
git log --oneline -- config/database.yml    # (1)!
git blame config/database.yml | head -20   # (2)!
```

1. `--` explicitly separates git options from the file path. Without it, git may misinterpret the path as a branch name. `--oneline` condenses each commit to a single line: hash + subject.
2. Who last changed each line.

`git blame` output shows you the commit hash, author, date, and content of each line:

```
a3f2c19 (Jane Smith    2024-01-10 14:23:11) pool_size: 20
b891de4 (Bob Johnson   2024-01-08 09:15:44) connect_timeout: 30
d523ef2 (Jane Smith    2024-01-05 16:30:02) host: db-primary.internal
```

**Key insight:** The commit authors are the people who know this code. Their names tell you who to ask; the commit messages tell you what questions are worth asking.

---

## Config Files as Documentation

Config files are the ground truth of how a service is actually running. Documentation describes defaults and options; the config file shows you what was actually chosen and why — especially when accompanied by comments:

``` bash title="Find Config Files" linenums="1"
ls /etc/nginx/
ls /etc/nginx/sites-enabled/
find /etc -name "*.conf" -maxdepth 2 2>/dev/null
```

Read the active configuration:

``` bash title="Read Active Configuration" linenums="1"
cat /etc/nginx/nginx.conf
less /etc/nginx/sites-enabled/default
```

Well-maintained config files often have comments explaining decisions that weren't obvious:

```nginx
# Increased from default 65 to handle payment webhook burst traffic
# See: https://jira.company.com/PAYMENTS-1234
worker_connections 1024;

# Upstream timeout set conservatively — payment provider SLA is 10s
proxy_read_timeout 15s;
```

When config files aren't commented, search for the interesting parts:

``` bash title="Search Config Files" linenums="1"
grep -r "listen\|server_name\|root" /etc/nginx/sites-enabled/
grep -r "timeout\|pool" /etc/payments-api/
```

---

## Quick Reference

``` bash title="Documentation Hunt" linenums="1"
# Built-in command help
man nginx
man 5 sshd_config          # (1)!
nginx --help

# System state
cat /etc/motd
systemctl list-units --type=service --state=running
systemctl cat servicename

# Application docs
find /var/www /opt /home -name "README*" 2>/dev/null
find /var /opt /home /usr/local -name "deploy*" -type f 2>/dev/null | head -20

# Package docs
ls /usr/share/doc/packagename/

# Git history
find /var /opt /home -name ".git" -type d 2>/dev/null | head -10
git log --oneline -20
git log --oneline -- path/to/file
git blame filename | head -30

# Config files
ls /etc/servicename/
grep -r "keyword" /etc/servicename/
```

1. Config file format (section 5).

---

## Practice Problems

??? question "Problem 1: Understand an Installed Service"
    You find nginx is running on an unfamiliar server. Using only what's available on the server, find out: what version is it, where is its config, how is it configured to start, and what does the server's package README say?

    ??? tip "Answer"
        ``` bash title="Investigate nginx" linenums="1"
        nginx -v                       # (1)!
        nginx --help                   # (2)!
        man nginx                      # (3)!
        man 5 nginx                    # (4)!
        systemctl cat nginx            # (5)!
        ls /etc/nginx/                 # (6)!
        cat /etc/nginx/nginx.conf      # (7)!
        ls /usr/share/doc/nginx/       # (8)!
        cat /usr/share/doc/nginx/README.Debian 2>/dev/null || cat /usr/share/doc/nginx/README
        ```

        1. Version.
        2. Available flags.
        3. Full manual.
        4. Config format (if available).
        5. Service unit file — how it's configured to run.
        6. Config structure.
        7. Active config.
        8. Package docs directory.

        Start with `systemctl cat nginx` — it tells you the binary path, the user it runs as, and where its config lives. From there you can find everything else. The package README tells you about distribution-specific changes that may explain why this installation behaves differently from the official documentation.

??? question "Problem 2: Understand a Deployed Application"
    You find a directory at `/opt/webapp`. Piece together what it is, what it does, and what the team has been working on recently — without running anything or asking anyone.

    ??? tip "Answer"
        ``` bash title="Understand a Deployed Application" linenums="1"
        ls -la /opt/webapp/                                         # (1)!
        cat /opt/webapp/README.md 2>/dev/null                       # (2)!
        find /opt/webapp -type d -name "docs" 2>/dev/null           # (3)!
        find /opt/webapp -name "deploy*" -o -name "Makefile" 2>/dev/null  # (4)!
        systemctl list-units --type=service | grep webapp           # (5)!
        systemctl cat webapp 2>/dev/null                            # (6)!
        cd /opt/webapp && git log --oneline -15 2>/dev/null         # (7)!
        ```

        1. What's here.
        2. Intent and overview.
        3. Docs directory.
        4. Deploy scripts.
        5. Is it a service?
        6. How does it run?
        7. Recent changes.

        The README tells you intent. The deploy scripts tell you the operational reality. `git log` tells you what the team has been changing recently — which often surfaces active problems or in-progress work. Between these three sources you can build a solid picture of any application without talking to anyone.

---

## Key Takeaways

| Source | Commands | What It Tells You |
|--------|----------|-------------------|
| Built-in help | `man cmd`, `man 5 config`, `cmd --help` | How commands and config files work |
| System state | `systemctl list-units`, `systemctl cat svc` | What's running and how it's deployed |
| Login message | `cat /etc/motd` | What the team wants you to know |
| README files | `find ... -name "README*"` | Application purpose and setup |
| Deploy scripts | `find ... -name "deploy*"` | How it's actually built and deployed |
| Package docs | `ls /usr/share/doc/packagename/` | Distribution-specific behaviour |
| Git history | `git log`, `git blame` | What changed, when, and who decided it |
| Config files | `ls /etc/svc/`, `grep -r "key" /etc/svc/` | How the service is actually configured |

## What's Next?

You know how to understand an unfamiliar server without leaving the terminal. Before you start making changes, read [The "Don't Do This" Guide](safety_guide.md) — the production safety rules that will keep you out of trouble.

---

## Further Reading

### Command References

- `man man` — Covers sections, searching, and finding the right page when a command has multiple manual entries
- `man find` — Full `find` options; `-maxdepth` limits scope, `-type f` restricts to files
- `man git-log` — History options including `--since`, `--author`, `--follow`, and format strings
- `man git-blame` — Track down who last modified specific lines; `-L` limits to a line range

### Official Documentation

- [The Linux Documentation Project](https://tldp.org/) — Guides, HOWTOs, and FAQs for Linux
- [GNU Coreutils Manual](https://www.gnu.org/software/coreutils/manual/) — The standard Linux command set, with more depth than the man pages
- [systemd Documentation](https://systemd.io/) — Unit file format, directives, and systemctl reference

### Related Articles

- [Orientation](orientation.md) — Identifying what's running and what resources the server has
- [Reading Logs](reading_logs.md) — Once you understand what's running, logs tell you how it's behaving

