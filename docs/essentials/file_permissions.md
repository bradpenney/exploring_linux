---
date: "2025-08-25 13:01"
title: File Permissions in Linux - chmod, chown, and umask
description: Learn to manage Linux file permissions — chmod, chown, umask, SUID, SGID, and sticky bit — the skills every sysadmin and DevOps engineer needs.
---

# File Permissions

!!! tip "Part of Essentials"
    This article is about *managing* permissions. If you need to understand the permission system — how to read `rwxr-xr-x`, why you get "Permission denied," or what the permission check order is — start with [Understanding Your Permissions](../day_one/permissions.md) in Day One.

You've inherited a web application with broken permissions. Files the web server should read are owned by the wrong user. A deployment script is missing its execute bit. A shared directory is letting users delete each other's work.

Knowing how to fix these — quickly and correctly — is a core sysadmin skill. This article is about taking action: changing permissions, adjusting ownership, controlling defaults, and understanding the special permission bits that show up in production environments.

---

## Where You've Seen This

If you've administered Windows, you know NTFS permissions: Read, Write, Execute, Modify, Full Control — applied per user or group via the Security tab. Linux permissions are a simplified version of the same model. The concepts map directly:

| Windows | Linux Equivalent |
|---------|-----------------|
| Read (R) | `r` (read) |
| Write (W) | `w` (write) |
| Execute (X) | `x` (execute) |
| Full Control | `rwx` for owner |
| Users and groups | Users and groups (same concept) |
| Owner | Owner (`u`) |
| Everyone | Other (`o`) |

What's different: Linux permissions are simpler (three entities: owner, group, other) and more transparent — `ls -l` shows you the exact permissions as a readable string. What NTFS buries in a dialog, Linux shows you in a `stat` command or an `ls -l`.

SUID and SGID have no clean Windows equivalent — they're Linux-specific elevation mechanisms. We cover them later in this article.

---

## The Tools at a Glance

``` mermaid
graph LR
    A["🔍 Problem:\nWrong access to a file or directory"] --> B{What needs\nto change?}
    B -->|"The permissions\n(rwx)"| C["chmod\nChange file mode bits"]
    B -->|"The owner\nor group"| D["chown / chgrp\nChange ownership"]
    B -->|"Default permissions\nfor new files"| E["umask\nDefault permission mask"]
    B -->|"Special behavior\n(SUID, SGID, sticky)"| F["chmod\nwith special bits"]

    style A fill:#1a202c,stroke:#cbd5e0,stroke-width:2px,color:#fff
    style C fill:#2d3748,stroke:#68d391,stroke-width:2px,color:#fff
    style D fill:#2d3748,stroke:#63b3ed,stroke-width:2px,color:#fff
    style E fill:#2d3748,stroke:#d69e2e,stroke-width:2px,color:#fff
    style F fill:#2d3748,stroke:#fc8181,stroke-width:2px,color:#fff
```

---

## chmod — Changing Permissions

`chmod` (change file mode) has two notations: **symbolic** for surgical changes to specific bits, and **octal** for setting exact permissions in one step.

### Symbolic Notation

Symbolic notation describes what to change: who, what operation, and which permissions.

``` bash title="Symbolic chmod Syntax"
chmod [who][operator][permissions] file
#      u/g/o/a  +/-/=    r/w/x
```

| Who | Meaning |
|-----|---------|
| `u` | User (owner) |
| `g` | Group |
| `o` | Other |
| `a` | All (user + group + other) |

| Operator | Meaning |
|----------|---------|
| `+` | Add permission |
| `-` | Remove permission |
| `=` | Set exactly (overwrite existing) |

``` bash title="Symbolic chmod Examples"
chmod u+x script.sh         # (1)!
chmod g-w config.conf       # (2)!
chmod o= sensitive.key      # (3)!
chmod a+r shared.txt        # (4)!
chmod u+x,g-w,o= deploy.sh  # (5)!
chmod +x deploy.sh          # (6)!
```

1. Add execute for the owner.
2. Remove write from the group.
3. Remove all permissions from others.
4. Add read for everyone.
5. Combine multiple changes in one command.
6. Make a script executable — a common pattern, equivalent to `chmod a+x`.

**When to use symbolic:** When you want to add or remove a specific bit without disturbing the rest. `chmod +x` for shell scripts is one of the most common uses — see [Your First Bash Script](bash_first_script.md) for how this fits into the scripting workflow.

### Octal Notation

Octal assigns a number to each permission bit and sums them:

| Permission | Value |
|------------|-------|
| Read (`r`) | 4 |
| Write (`w`) | 2 |
| Execute (`x`) | 1 |
| None (`-`) | 0 |

Three digits cover owner, group, and other:

``` bash title="Octal chmod Examples"
chmod 644 config.conf       # (1)!
chmod 755 deploy.sh         # (2)!
chmod 600 ~/.ssh/id_rsa     # (3)!
chmod 700 ~/.ssh/           # (4)!
chmod 775 /var/www/html/    # (5)!
```

1. `rw-r--r--` — owner read/write, group read, other read.
2. `rwxr-xr-x` — owner full, group and other read/execute.
3. `rw-------` — owner read/write, nobody else.
4. `rwx------` — owner full, nobody else.
5. `rwxrwxr-x` — owner and group full, other read/execute.

**Calculating octal:** Add the values for each permission set.

```
rwx = 4+2+1 = 7
rw- = 4+2+0 = 6
r-x = 4+0+1 = 5
r-- = 4+0+0 = 4
--- = 0+0+0 = 0
```

So `rwxr-xr--` = `7` `5` `4` = `754`.

**When to use octal:** When you want to set all permissions at once and you know exactly what you want. Common in scripts and documentation.

### Common Permission Patterns

| Pattern | Octal | Who It's For | Typical Use |
|---------|-------|-------------|-------------|
| `rw-r--r--` | 644 | Owner rw, everyone r | Config files, web content |
| `rw-------` | 600 | Owner only | SSH private keys, secrets |
| `rwxr-xr-x` | 755 | Owner rwx, everyone rx | Executables, directories |
| `rwx------` | 700 | Owner only | Private directories |
| `rwxrwxr-x` | 775 | Owner+group rwx, others rx | Shared team directories |
| `rw-rw-r--` | 664 | Owner+group rw, others r | Shared files |

### Recursive chmod

`chmod -R` recursively changes permissions on a directory and all its contents:

``` bash title="Recursive chmod"
chmod -R 755 /var/www/html/
```

!!! warning "chmod -R Can Cause Problems"
    `chmod -R 755` sets the same permissions on both directories and files. For web content, you usually want `755` on directories (so the web server can traverse them) but `644` on files (no execute for web content). Running `chmod -R 755` on files is usually a mistake.

    **The right approach** for web directories:

    ``` bash title="Correct Permissions for Web Content"
    find /var/www/html -type d -exec chmod 755 {} +   # (1)!
    find /var/www/html -type f -exec chmod 644 {} +   # (2)!
    ```

    1. Directories get `755` — the web server needs execute to traverse them.
    2. Files get `644` — readable, not executable.

    This is the pattern you'll use repeatedly on production web servers.

---

## chown — Changing Ownership

`chown` changes who owns a file and which group it belongs to. You'll need `sudo` unless you own the file.

``` bash title="chown Syntax and Examples"
chown jsmith file.txt                       # (1)!
chown jsmith:developers file.txt            # (2)!
chown :developers file.txt                  # (3)!
chown -R www-data:www-data /var/www/html/   # (4)!
ls -la file.txt                             # (5)!
```

1. Change owner only.
2. Change owner and group.
3. Change group only — note the colon prefix; equivalent to `chgrp developers file.txt`.
4. Recursive: change everything in a directory.
5. Verify the change.

### chgrp — Changing Group Only

`chgrp` is a dedicated command for changing just the group:

``` bash title="chgrp Examples"
chgrp developers project-files/
chgrp -R www-data /var/www/html/
```

In practice, `chown :group` and `chgrp group` are interchangeable. Most engineers use `chown` for both since it handles both owner and group in one command.

### Common Ownership Patterns

``` bash title="Typical Ownership Operations"
chown -R www-data:www-data /var/www/myapp/   # (1)!
chown -R jsmith:jsmith /opt/myapp/           # (2)!
chown root:root /etc/nginx/nginx.conf        # (3)!
ls -la /etc/nginx/                           # (4)!
```

1. Fix web server file ownership after a deploy.
2. Give a developer ownership of their application directory.
3. Reset ownership after copying from another system.
4. Check who owns everything in a directory.

---

## umask — Default Permissions

When you create a new file or directory, what permissions does it get? The answer is `umask`.

`umask` is a subtraction mask applied to the maximum possible permissions:

- New **files** start at `0666` (rw-rw-rw-)
- New **directories** start at `0777` (rwxrwxrwx)
- The umask is subtracted from these defaults

``` bash title="Checking and Setting umask"
umask           # (1)!
# 0022   ← the common default
```

1. `0022` is the common default. The mask is subtracted from the base permissions: `0666 - 022 = 644` (files become `rw-r--r--`) and `0777 - 022 = 755` (directories become `rwxr-xr-x`).

**Common umask values:**

| umask | File Default | Directory Default | Use Case |
|-------|-------------|-------------------|----------|
| `022` | 644 | 755 | Standard — others can read, not write |
| `027` | 640 | 750 | Secure — group can read, others nothing |
| `077` | 600 | 700 | Very private — owner only |
| `002` | 664 | 775 | Collaborative — group can write too |

``` bash title="Setting umask"
umask 027                       # (1)!
echo "umask 027" >> ~/.bashrc   # (2)!
source ~/.bashrc
```

1. Applies to the current shell session only.
2. Make it permanent — add it to `~/.bashrc` (or `~/.profile`), then it loads in every new shell.

??? tip "umask in Production"
    In many production environments, a `umask` of `027` is set system-wide in `/etc/profile` or `/etc/profile.d/` for security compliance. This ensures new files are never world-readable by default. If you're creating files that the web server needs to read, you may need to explicitly `chmod` them after creation.

---

## Special Permission Bits

Beyond `rwx`, Linux has three special permission bits. You'll encounter all three on production systems.

### SUID — Set User ID

**SUID** causes a file to execute as its *owner*, not the user who runs it. This is how non-root users can do things that require elevated privileges.

``` bash title="SUID in Action"
ls -la /usr/bin/passwd     # (1)!
# -rwsr-xr-x 1 root root 63960 Feb 7 12:00 /usr/bin/passwd
#    ^
#    's' in the owner execute position = SUID set
```

1. Any user can run `passwd` and it executes as root (because root owns it) — that's how users change their own passwords without `sudo`.

The `s` in the execute position means SUID is set. If the execute bit is also set, it shows as lowercase `s`. If execute is not set, it shows as uppercase `S` (meaning SUID is set but the file isn't executable — usually a misconfiguration).

``` bash title="Setting SUID"
chmod u+s /usr/bin/myapp    # (1)!
chmod 4755 myapp            # (2)!
```

1. Symbolic.
2. Octal — the `4` prefix sets SUID.

!!! warning "SUID is a Security Concern"
    Any SUID binary owned by root runs with full root privileges, regardless of who launches it. A vulnerable SUID binary can be exploited for privilege escalation. Security hardening includes auditing SUID files:

    ``` bash title="Find All SUID Files"
    find / -perm -4000 -type f 2>/dev/null
    ```

    Know what's on that list. Anything unexpected deserves investigation.

### SGID — Set Group ID

**SGID** on a **file** causes it to execute as the file's group (similar to SUID). On a **directory**, it causes new files created inside to inherit the directory's group automatically — extremely useful for shared team directories.

``` bash title="SGID on Directories"
mkdir /opt/project              # (1)!
chown root:developers /opt/project
chmod g+s /opt/project          # (2)!

ls -la /opt/
# drwxrwsr-x  2 root developers 4096 Mar 10 09:00 project
#        ^
#        's' in group execute position = SGID set

touch /opt/project/README.md    # (3)!
ls -la /opt/project/README.md
# -rw-rw-r-- 1 jsmith developers 0 Mar 10 09:01 README.md
#                      ^^^^^^^^^^
#                      inherited from directory, not jsmith's primary group
```

1. Create a shared project directory.
2. Set SGID — now any file created inside inherits the `developers` group, even if the creator's primary group is different.
3. Create a file to prove it: the new file picks up the `developers` group from the directory, not the creator's primary group.

``` bash title="Setting SGID"
chmod g+s /opt/project       # (1)!
chmod 2775 /opt/project      # (2)!
```

1. Symbolic.
2. Octal — the `2` prefix sets SGID.

**When to use SGID on directories:** Any shared team directory where multiple users create files and all team members need to access them. Without SGID, files end up owned by whoever created them with their primary group — causing access headaches.

### Sticky Bit

The **sticky bit** on a **directory** means that only the file's owner (or root) can delete or rename files inside it, even if other users have write permission on the directory.

``` bash title="The Sticky Bit"
ls -la /tmp     # (1)!
# drwxrwxrwt  18 root root 420 Mar 10 09:35 /tmp
#           ^
#           't' in other execute position = sticky bit set
```

1. `/tmp` is writable by everyone, but you can only delete your own files.

This is why `/tmp` works safely — everyone can write temporary files, but nobody can delete someone else's work.

``` bash title="Setting the Sticky Bit"
chmod +t /shared/uploads/        # (1)!
chmod 1777 /shared/uploads/      # (2)!
```

1. Symbolic.
2. Octal — the `1` prefix sets the sticky bit.

**When to use sticky bit:** Any directory where multiple users write files and shouldn't be able to delete each other's work. Upload directories, shared scratch space.

---

## Common Scenarios

=== "Fix a Broken Deployment"

    A new application was deployed but the web server can't read the files. The files are owned by the `deploy` user but the web server runs as `www-data`.

    ``` bash title="Fix Deployment Permissions"
    ls -la /var/www/myapp/                              # (1)!
    chown -R www-data:www-data /var/www/myapp/          # (2)!
    find /var/www/myapp -type d -exec chmod 755 {} +    # (3)!
    find /var/www/myapp -type f -exec chmod 644 {} +    # (4)!
    chmod 755 /var/www/myapp/run.sh                     # (5)!
    ```

    1. Diagnose — check what's there.
    2. Fix ownership so the web server owns the files.
    3. Directories traversable (`755`).
    4. Files readable (`644`).
    5. If there are executable scripts the web server needs to run.

=== "Set Up a Shared Team Directory"

    Multiple developers need to write to `/opt/project/`. New files should automatically be accessible to the whole team.

    ``` bash title="Set Up Shared Directory"
    mkdir /opt/project                  # (1)!
    chown root:developers /opt/project
    chmod 775 /opt/project              # (2)!
    chmod g+s /opt/project              # (3)!
    ls -la /opt/                        # (4)!
    # drwxrwsr-x 2 root developers 4096 Mar 10 09:00 project
    ```

    1. Create and own the directory.
    2. Team can read/write, others can read.
    3. Set SGID so new files inherit the `developers` group.
    4. Verify.

=== "Secure Sensitive Files"

    Private keys, credentials, and sensitive configuration need restrictive permissions to pass security audits.

    ``` bash title="Secure Sensitive Files"
    chmod 600 ~/.ssh/id_rsa                          # (1)!
    chmod 700 ~/.ssh/
    chown appuser:appuser /etc/myapp/secrets.env     # (2)!
    chmod 600 /etc/myapp/secrets.env
    find /etc/myapp -type f -perm /o+r 2>/dev/null   # (3)!
    ```

    1. SSH private key — owner read-only, nobody else.
    2. Application secrets — only the app user.
    3. Verify there are no world-readable secrets — any output here means a file is world-readable, so review it.

=== "Audit Permissions"

    Something is behaving unexpectedly and you suspect a permissions problem. Systematic audit approach:

    ``` bash title="Permissions Audit"
    ls -la /path/to/target                          # (1)!
    namei -l /path/to/target/file                   # (2)!
    find /var/www -perm -002 -type f 2>/dev/null    # (3)!
    find / -perm -4000 -type f 2>/dev/null          # (4)!
    find /opt -nouser 2>/dev/null                   # (5)!
    ```

    1. Check the file or directory in question.
    2. Check every directory in the path — `namei -l` shows permissions at each level of the traverse chain.
    3. Find world-writable files (a potential security issue).
    4. Find SUID files — should be a known, short list.
    5. Find files with no valid owner (orphaned files).

---

## Quick Reference

### chmod Cheat Sheet

| Goal | Symbolic | Octal |
|------|----------|-------|
| Owner can read and write | `chmod u=rw file` | `chmod 600 file` |
| Owner rwx, others r-x | `chmod u=rwx,go=rx file` | `chmod 755 file` |
| Owner rw, group r, others nothing | `chmod u=rw,g=r,o= file` | `chmod 640 file` |
| Add execute for everyone | `chmod a+x file` | — |
| Remove write from group and other | `chmod go-w file` | — |
| Directories 755, files 644 | `find . -type d -exec chmod 755 {} +` | — |
| Set SUID | `chmod u+s file` | `chmod 4755 file` |
| Set SGID on directory | `chmod g+s dir/` | `chmod 2775 dir/` |
| Set sticky bit | `chmod +t dir/` | `chmod 1777 dir/` |

### Special Bits in ls Output

| ls Shows | What It Means |
|----------|--------------|
| `rws` in owner position | SUID set (file runs as owner) |
| `rwS` in owner position | SUID set but execute bit missing (likely a problem) |
| `rws` in group position | SGID set (file runs as group / dir inherits group) |
| `rwt` in other position | Sticky bit set (only owner can delete) |

---

## Practice Exercises

??? question "Exercise 1: Octal to Symbolic"
    Without running any commands, translate these octal permissions to the `rwx` notation:

    1. `chmod 644`
    2. `chmod 755`
    3. `chmod 600`
    4. `chmod 4755`

    ??? tip "Solution"
        1. `644` → `rw-r--r--` (owner: rw, group: r, other: r)
        2. `755` → `rwxr-xr-x` (owner: rwx, group: rx, other: rx)
        3. `600` → `rw-------` (owner: rw, nobody else)
        4. `4755` → `rwsr-xr-x` (755 + SUID = `s` in owner position)

        To verify: `stat -c "%A" /etc/hosts` shows symbolic permissions; `stat -c "%a" /etc/hosts` shows octal.

??? question "Exercise 2: Fix Web Server Permissions"
    You've deployed a web application to `/var/www/myapp/`. The web server runs as `www-data`. Files are currently owned by `deploy:deploy` with permissions `700`.

    Write the commands to fix this so:

    - The web server can read all files
    - The web server cannot write any files (security requirement)
    - The `deploy` user can still read and write

    ??? tip "Solution"
        ``` bash title="Fix Web Server Permissions"
        chown -R deploy:www-data /var/www/myapp/            # (1)!
        find /var/www/myapp -type d -exec chmod 750 {} +   # (2)!
        find /var/www/myapp -type f -exec chmod 640 {} +   # (3)!
        ```

        1. Use a shared group — `deploy` stays the owner, `www-data` becomes the group.
        2. Directories `750` (`rwxr-x---`) — deploy can write, www-data can traverse, others nothing.
        3. Files `640` (`rw-r-----`) — deploy can write, www-data can read, others nothing.

        This setup: `deploy` (owner) can write files during deployment. `www-data` (group) can read files during serving. Others have no access.

??? question "Exercise 3: Shared Directory Setup"
    Your team uses `/opt/shared/` for shared project files. Files created by one developer should automatically be accessible to the whole `devteam` group. Set this up correctly.

    ??? tip "Solution"
        ``` bash title="Shared Directory Setup"
        chown root:devteam /opt/shared/    # (1)!
        chmod 775 /opt/shared/             # (2)!
        chmod g+s /opt/shared/             # (3)!
        ls -ld /opt/shared/                # (4)!
        # drwxrwsr-x 2 root devteam 4096 Mar 10 09:00 /opt/shared/
        #        ^
        #        's' confirms SGID is set
        ```

        1. Set ownership to the `devteam` group.
        2. `775` (`rwxrwxr-x`) — team members can read and write, others read and traverse.
        3. Set SGID so new files inherit the `devteam` group.
        4. Verify.

---

## Quick Recap

- **`chmod`** — change permissions; symbolic (`u+x`) for surgical changes, octal (`755`) for exact settings
- **`chown`** — change owner and/or group: `chown user:group file`; `-R` for recursive
- **`umask`** — sets default permissions for new files: `022` gives files 644, dirs 755
- **SUID** (`u+s` / `4xxx`) — file executes as its owner; security-sensitive, audit regularly
- **SGID** (`g+s` / `2xxx`) — file executes as its group; on directories, new files inherit the group
- **Sticky bit** (`+t` / `1xxx`) — on directories, only owners can delete their own files
- **Web server pattern:** `chown -R www-data:www-data`, then `find -type d -exec chmod 755`, `find -type f -exec chmod 644`

---

## Further Reading

### Command References

- `man chmod` — complete chmod documentation including special bits
- `man chown` — ownership change options
- `man chgrp` — group change command
- `man umask` — umask in the bash manual
- `man namei` — follow a pathname and show permissions at each level
- `man getfacl` — Access Control Lists (when standard permissions aren't enough)
- `man setfacl` — set fine-grained ACL permissions

### Deep Dives

- [Red Hat: Managing File Permissions](https://www.redhat.com/sysadmin/linux-file-permissions-explained) — comprehensive Red Hat guide
- [Linux File Permissions and Attributes](https://wiki.archlinux.org/title/File_permissions_and_attributes) — Arch Wiki deep dive on permissions and ACLs
- [Understanding SUID, SGID, and Sticky Bits](https://www.redhat.com/sysadmin/suid-sgid-sticky-bit) — Red Hat's guide to special permission bits

### Official Documentation

- [Red Hat: Managing File Ownership](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/configuring_basic_system_settings/assembly_managing-file-permissions_configuring-basic-system-settings) — RHEL permission management
- [GNU Coreutils: chmod](https://www.gnu.org/software/coreutils/manual/html_node/chmod-invocation.html) — authoritative chmod reference
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks) — industry security configurations including permission hardening

---

## What's Next?

Permissions control what files users can access. But managing which users exist and which groups they belong to is a separate skill — and one that directly shapes the permission model across your entire system.

Head to **[Users and Groups](users_and_groups.md)** to learn how to create and manage user accounts, add users to groups, and understand the `/etc/passwd` and `/etc/group` files that underpin Linux's identity system.
