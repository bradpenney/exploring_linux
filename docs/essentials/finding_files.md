---
date: "2025-08-26 08:59"
title: Finding Files in Linux - find, locate, and which
description: Master Linux file discovery with find, locate, and which — learn to locate configs, logs, binaries, and large files on any system you encounter.
---

# Finding Files

!!! tip "Part of Essentials"
    This article assumes familiarity with the [Filesystem Hierarchy](filesystem_hierarchy.md). Knowing where things *should* be makes finding them much faster.

You've just been handed access to a server you've never seen before. There's an application running — you need to find its config file. Or maybe disk space is critically low and you need to find what's eating it. Or a log file rotated and you're not sure where the compressed version ended up.

These are daily situations for sysadmins and DevOps engineers. The difference between 30 seconds and 30 minutes is knowing which tool to reach for.

---

## Where You've Seen This

On Windows, you'd use File Explorer's search or the `where` command for executables. In your IDE, it's Ctrl+Shift+F (find in files). Those work on a single machine with a GUI. On Linux servers — often headless, often under load, often in the middle of an incident — you need tools that work fast from the command line and compose into scripts.

`find` in particular shows up everywhere: deployment scripts, cron jobs, log rotation configs, CI pipelines. Learning it interactively is also learning the tool you'll write in automation. The patterns transfer directly.

!!! tip "Why Speed Matters Here"
    When something breaks in production, finding the right config or log file fast isn't a convenience — it's the job. `find /etc -name "*.conf" -mtime -1` tells you everything that changed in configuration in the last 24 hours in seconds. Knowing `find` cold is one of the clearest separators between engineers who thrive in Linux environments and those who struggle.

---

## Choosing the Right Tool

``` mermaid
graph TD
    A[What are you looking for?] --> B{Is it an executable\nor command?}
    B -->|Yes| C["which / type -a\nFinds binaries in PATH"]
    B -->|No| D{Do you know\nthe file name?}
    D -->|Yes, need speed| E["locate\nSearches a pre-built database"]
    D -->|Yes, need precision| F["find -name\nLive filesystem search"]
    D -->|No, but know other traits| G["find with filters\n-size, -mtime, -user, -type"]
    D -->|No, but know the contents| H["grep -r\nSearch inside files"]

    H --> I["See: grep article"]

    style A fill:#d69e2e,stroke:#cbd5e0,stroke-width:2px,color:#000
    style C fill:#2d3748,stroke:#68d391,stroke-width:2px,color:#fff
    style E fill:#2d3748,stroke:#63b3ed,stroke-width:2px,color:#fff
    style F fill:#2d3748,stroke:#fc8181,stroke-width:2px,color:#fff
    style G fill:#2d3748,stroke:#fc8181,stroke-width:2px,color:#fff
    style H fill:#2d3748,stroke:#718096,stroke-width:2px,color:#fff
    style I fill:#1a202c,stroke:#718096,stroke-width:1px,color:#9ca3af
```

---

## The Tools

<div class="grid cards" markdown>

-   :material-magnify: **which / type -a — Finding Executables**

    ---

    **Why it matters:** When you run `nginx`, what binary actually runs? `which` shows you the first match. `type -a` shows every match across your entire `$PATH` — critical when you have multiple versions installed.

    ``` bash title="Finding Executable Locations"
    which nginx
    # /usr/sbin/nginx

    which python3
    # /usr/bin/python3

    type -a python3
    # python3 is /usr/bin/python3
    # python3 is /usr/local/bin/python3   ← virtualenv or custom install
    ```

    **Key insight:** If `which` returns nothing, the command isn't in your `$PATH`. It might be installed but not on your PATH, or not installed at all. Use `find` next.

-   :material-database-search: **locate — Fast Name Search**

    ---

    **Why it matters:** `locate` searches a pre-built index instead of crawling the filesystem live. It's orders of magnitude faster than `find` for interactive name searches.

    ``` bash title="Using locate"
    locate nginx.conf
    # /etc/nginx/nginx.conf
    # /usr/share/doc/nginx/examples/nginx.conf

    locate -i readme   # (1)!
    ```

    1. `-i` makes it case-insensitive.

    **Key insight:** `locate` can be stale — it won't find files created since the last database update. Run `sudo updatedb` to refresh it. On many systems this runs nightly via cron, but on new servers or fresh installs it may never have run.

    ``` bash title="Update locate Database"
    sudo updatedb       # (1)!
    locate myapp.conf   # (2)!
    ```

    1. refresh the database.
    2. now it will find newly created files.

-   :material-file-search: **find — Flexible Filesystem Search**

    ---

    **Why it matters:** `find` walks the filesystem live. It's slower than `locate` but can search by name, type, size, age, owner, permissions, or any combination. Indispensable for scripts because it's always accurate.

    ``` bash title="find Basics"
    find /etc -name "nginx.conf"
    # /etc/nginx/nginx.conf

    find /var/log -name "*.log" -type f   # (1)!

    find / -name "hosts" 2>/dev/null    # (2)!
    # /etc/hosts
    # /var/lib/docker/containers/.../hosts
    ```

    1. finds only files (not dirs) named `*.log` under `/var/log`.
    2. `2>/dev/null` silences "Permission denied" errors for directories you can't read. The `2>` redirects stderr (file descriptor 2) to `/dev/null` (the discard device), keeping stdout clean.

    **Key insight:** `find` is the right tool for scripts. `locate` is fast but can return stale results. In automation, always use `find`.

-   :material-text-search: **grep -r — Search by Content**

    ---

    **Why it matters:** Sometimes you know what's *inside* a file but not the filename. `grep -r` searches file contents recursively.

    ``` bash title="Searching File Contents"
    grep -r "database_host" /etc/myapp/
    # /etc/myapp/config.yml:  database_host: db-prod-01

    grep -rl "FAILED" /var/log/    # (1)!
    # /var/log/auth.log
    # /var/log/application/app.log
    ```

    1. `-r` searches recursively. `-l` shows only filenames, not the matching lines — useful when you want to know *which files* contain a pattern, not the lines themselves.

    **Key insight:** `grep -r` is for content; `find` is for file attributes. See the [grep article](grep.md) for the full story on searching inside files.

</div>

---

## Mastering find

`find` has a reputation for being intimidating. The syntax is unusual, but the pattern is consistent: `find [where] [what criteria] [what to do]`.

Once you internalize the common filters, you'll reach for `find` constantly.

### Filtering by Name

``` bash title="Name-Based Searches"
find /etc -name "*.conf"            # (1)!
find /etc -name "nginx*"            # (2)!
find /etc -iname "Nginx.conf"       # (3)!
find / -name "authorized_keys" 2>/dev/null   # (4)!
```

1. files ending in `.conf`.
2. files starting with `nginx`.
3. `-iname` is case-insensitive.
4. find SSH auth keys anywhere.

### Filtering by Type

``` bash title="Type-Based Searches"
find /var/log -type f       # (1)!
find /etc -type d           # (2)!
find /usr/bin -type l       # (3)!
```

1. files only (not directories).
2. directories only.
3. symbolic links only.

### Filtering by Size

``` bash title="Size-Based Searches"
find / -type f -size +100M 2>/dev/null     # (1)!
find /var -type f -size +10M 2>/dev/null   # (2)!
find /tmp -type f -size -1k                # (3)!
```

1. files larger than 100MB.
2. files in `/var` larger than 10MB.
3. files smaller than 1KB.

Size units: `c` (bytes), `k` (kilobytes), `M` (megabytes), `G` (gigabytes). Prefix with `+` for "greater than", `-` for "less than".

### Filtering by Age

``` bash title="Age-Based Searches"
find /var/log -name "*.log" -mtime -7      # (1)!
find /tmp -type f -mtime +30               # (2)!
find /etc -newer /etc/hosts                # (3)!
find /var/log -name "*.log" -mmin -60      # (4)!
```

1. modified in the last 7 days.
2. not modified in 30+ days.
3. modified more recently than `/etc/hosts`.
4. modified in the last 60 minutes.

`-mtime` counts in days. `-mmin` counts in minutes. `+N` means "older than N", `-N` means "newer than N" (confusingly, but consistently).

### Filtering by Owner and Permissions

``` bash title="Owner and Permission Searches"
find /home -user jsmith             # (1)!
find /var/www -group www-data       # (2)!
find / -perm -4000 2>/dev/null      # (3)!
find / -perm -002 2>/dev/null       # (4)!
```

1. files owned by jsmith.
2. files owned by www-data group.
3. SUID files (potential security concern).
4. world-writable files.

### Combining Filters

Filters combine with implicit AND by default. Use `-o` for OR and `!` for NOT:

``` bash title="Combining Filters"
find /var/log -type f -size +10M -mtime -7   # (1)!

find /etc -name "*.conf" -o -name "*.crt"   # (2)!

find /tmp -type f ! -user root   # (3)!
```

1. Files in `/var/log`, larger than 10MB, modified in the last week.
2. Config files OR certificate files in `/etc`.
3. Files in `/tmp` not owned by root.

---

## Acting on Results: -exec and xargs

Finding files is only half the job. Often you need to do something with them.

### -exec: Run a Command on Each Result

``` bash title="Using -exec"
find /etc -name "*.conf" -exec cat {} \;    # (1)!

find /var/www -type f -exec ls -lh {} \;   # (2)!

find /tmp -type f -mtime +30 -exec rm {} \;   # (3)!
```

1. View every `.conf` file found. `{}` is replaced by the filename for each result; `\;` ends the `-exec` expression (the backslash escapes the semicolon from shell interpretation).
2. Check permissions on found files.
3. Delete files older than 30 days in `/tmp`.

**Efficiency note:** `-exec command {} \;` runs the command once per file. For large result sets, use `+` instead — it passes all results at once:

``` bash title="-exec with + (More Efficient)"
find /etc -name "*.conf" -exec ls -lh {} +   # (1)!
```

1. Runs `ls -lh file1 file2 file3 ...` as a single invocation.

### xargs: Pipe Results to Another Command

`xargs` takes input from stdin and passes it as arguments to a command:

``` bash title="Using xargs"
find /etc -name "*.conf" | xargs grep "listen"   # (1)!

find /var/log -name "*.log" -mtime +30 | xargs ls -lh   # (2)!
```

1. searches all `.conf` files for "listen".
2. list details of all old log files.

**Handling filenames with spaces:** The default behavior breaks on spaces. Use `-print0` and `xargs -0` for safety:

``` bash title="Safe xargs with Spaces in Filenames"
find /home -type f -name "*.txt" -print0 | xargs -0 grep "password"   # (1)!
```

1. `-print0` uses null bytes as delimiters instead of newlines; `xargs -0` reads that null-delimited input.

This is a best practice in scripts. For interactive use, the simple pipe is usually fine.

---

## Common Real-World Patterns

=== "Find a Config File"

    You know a service is configured somewhere but don't know the exact path.

    ``` bash title="Hunting Config Files"
    # By service name (usually works)
    find /etc -name "*nginx*" -type f
    find /etc -name "*postgresql*" -type f

    # By extension
    find /etc -name "*.conf" -type f | grep -i myapp
    find /etc -name "*.yml" -o -name "*.yaml" | xargs grep -l "myapp" 2>/dev/null

    # Service unit files often point to the config
    systemctl cat myapp.service | grep -i "config\|conf\|env"
    ```

    **Pattern:** Start with the service name. If that fails, look for the config in the unit file — it usually references the path directly.

=== "Find Large Files Eating Disk"

    Disk is full. Need to find what's consuming space fast.

    ``` bash title="Finding Large Files"
    find / -type f -size +100M 2>/dev/null | xargs ls -lh | sort -k5 -hr   # (1)!

    find /var -type f -size +50M 2>/dev/null   # (2)!

    find /var -type f -size +10M -mtime -1 2>/dev/null   # (3)!
    ```

    1. Files over 100MB anywhere on the filesystem.
    2. In `/var` specifically (where most growth happens).
    3. Recently modified large files (a growing problem).

    **Pattern:** Combine `du -sh /var/* | sort -hr | head -10` (from the [Filesystem Hierarchy](filesystem_hierarchy.md) article) to find which directory is growing, then drill in with `find -size`.

=== "Find Recently Changed Files"

    Something broke recently. You want to know what changed.

    ``` bash title="Finding Recent Changes"
    find /etc -type f -mtime -1   # (1)!

    find /etc /var/lib /opt -type f -mmin -60 2>/dev/null   # (2)!

    find /etc -newer /etc/hosts -type f    # (3)!
    ```

    1. Files changed in the last 24 hours in `/etc`.
    2. Files changed in the last hour across key dirs.
    3. Files newer than a reference file (useful after incidents) — changed after `/etc/hosts` was last modified.

    **Pattern:** Set a reference point first — `touch /tmp/checkpoint` — then later run `find / -newer /tmp/checkpoint` to see everything that changed since.

=== "Find Files by Owner"

    Auditing user files, or tracking down orphaned files after a user was removed.

    ``` bash title="Finding Files by Owner"
    find /home /var /opt -user jsmith 2>/dev/null   # (1)!

    find / -nouser 2>/dev/null | head -20   # (2)!

    find /home -user root -type f 2>/dev/null   # (3)!
    ```

    1. All files owned by a specific user.
    2. Files with no valid owner (user was deleted).
    3. Files owned by root in a directory that shouldn't have them.

---

## Quick Reference

### Tool Selection

| Tool | Speed | Accuracy | Best For |
|------|-------|----------|----------|
| `which` | Instant | Always current | Finding executables in `$PATH` |
| `type -a` | Instant | Always current | Finding all versions of an executable |
| `locate` | Very fast | May be stale | Interactive name search |
| `find` | Moderate | Always current | Scripts, precise searches, multiple criteria |

### find Filter Cheatsheet

| Filter | Example | What It Matches |
|--------|---------|-----------------|
| `-name` | `-name "*.conf"` | Files matching the pattern (case-sensitive) |
| `-iname` | `-iname "*.Conf"` | Case-insensitive name match |
| `-type f` | `-type f` | Regular files only |
| `-type d` | `-type d` | Directories only |
| `-type l` | `-type l` | Symbolic links only |
| `-size +N` | `-size +100M` | Larger than N |
| `-size -N` | `-size -1k` | Smaller than N |
| `-mtime -N` | `-mtime -7` | Modified in last N days |
| `-mtime +N` | `-mtime +30` | Not modified in N+ days |
| `-mmin -N` | `-mmin -60` | Modified in last N minutes |
| `-user` | `-user jsmith` | Owned by user |
| `-group` | `-group www-data` | Owned by group |
| `-nouser` | `-nouser` | No valid owner (deleted user) |
| `2>/dev/null` | (end of command) | Suppress permission errors |

---

## Practice Exercises

??? question "Exercise 1: Find a Known File"
    Find the SSH server configuration file on the system. You know it's named `sshd_config` but not the exact path.

    ??? tip "Solution"
        ``` bash title="Finding sshd_config"
        find /etc -name "sshd_config"
        # /etc/ssh/sshd_config
        ```

        Or with `locate` for speed:

        ``` bash title="Using locate"
        locate sshd_config
        # /etc/ssh/sshd_config
        # /usr/share/doc/openssh/examples/sshd_config
        ```

        Note that `locate` may return documentation copies too — `find` is more precise when you know the directory to start from.

??? question "Exercise 2: Disk Space Investigation"
    Find all files larger than 50MB in `/var`. List them with human-readable sizes, sorted largest first.

    ??? tip "Solution"
        ``` bash title="Finding Large Files in /var"
        find /var -type f -size +50M 2>/dev/null -exec ls -lh {} \; | sort -k5 -hr
        ```

        Or with xargs (more efficient for large result sets):

        ``` bash title="Using xargs for Large File Listing"
        find /var -type f -size +50M 2>/dev/null | xargs ls -lh 2>/dev/null | sort -k5 -hr
        ```

        `-k5` sorts by the 5th field of `ls -lh` output, which is the file size. `-h` sorts human-readable sizes correctly. `-r` reverses to largest first.

??? question "Exercise 3: Recent Changes Audit"
    Something changed in `/etc` in the last 24 hours and a service is now broken. Find all files modified recently so you know what to investigate.

    ??? tip "Solution"
        ``` bash title="Finding Recent Changes in /etc"
        find /etc -type f -mtime -1
        ```

        If the change happened within the last hour:

        ``` bash title="Very Recent Changes"
        find /etc -type f -mmin -60
        ```

        Once you find the file, check what changed with `diff` or look at git history if the team uses version control for configs (many do in production environments).

??? question "Exercise 4: Orphaned Files"
    A user `olddev` was removed from the system. Find all files they left behind under `/home`, `/var`, and `/opt`.

    ??? tip "Solution"
        ``` bash title="Finding Files by Deleted User"
        find /home /var /opt -user olddev 2>/dev/null   # (1)!

        find /home /var /opt -nouser 2>/dev/null   # (2)!
        ```

        1. If the username still resolves (user in `/etc/passwd` but shell removed).
        2. If the user was fully deleted, their files show a numeric UID.

        Files owned by a deleted user appear as a numeric UID in `ls -l` output (e.g., `1042` instead of `olddev`). `-nouser` catches these orphaned files.

---

## Quick Recap

- **`which`** — find a binary in `$PATH`; use `type -a` to find all versions
- **`locate`** — fast name search against a pre-built database; may be stale, run `sudo updatedb` to refresh
- **`find`** — live filesystem search; the right tool for scripts and precise searches
- **`find` filters:** `-name`, `-type`, `-size`, `-mtime`, `-user`, `-group`, `-nouser`
- **Acting on results:** `-exec command {} \;` for one-at-a-time, `-exec command {} +` for batch, `| xargs` for piping
- **Silence permission errors** with `2>/dev/null` — you'll use this constantly

---

## Further Reading

### Command References

- `man find` — the complete `find` manual; extensive and worth reading
- `man locate` — locate options and database management
- `man xargs` — full xargs documentation, including parallel execution with `-P`
- `man updatedb` — how the locate database is built and configured

### Deep Dives

- [GNU findutils Manual](https://www.gnu.org/software/findutils/manual/find.html) — the authoritative `find` reference
- [The Art of Command Line: Data Wrangling](https://github.com/jlevy/the-art-of-command-line#data-wrangling) — practical find and xargs patterns
- [Brendan Gregg: Linux Performance](https://www.brendangregg.com/linuxperf.html) — includes disk analysis using find

### Official Documentation

- [Red Hat: Finding Files](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/configuring_basic_system_settings/assembly_finding-files_configuring-basic-system-settings) — RHEL guide to find and locate
- [The Linux Documentation Project](https://tldp.org/) — Linux HOWTOs and guides

---

## What's Next?

You can now find any file on the system. The next skill is knowing how to get help when you encounter a command you've never seen before.

Head to **[Finding Help](finding_help.md)** to learn how to read man pages effectively, use `--help` flags, find information online, and extract what you need from documentation without reading every word.
