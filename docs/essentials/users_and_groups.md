---
title: Users and Groups in Linux - User Account Management
description: Master Linux user and group management — useradd, usermod, groupadd, service accounts, and the /etc/passwd and /etc/group files every sysadmin reads.
---

# Users and Groups

!!! tip "Part of Essentials"
    This article covers managing users and groups. For understanding your own access level — checking your groups, `sudo -l`, and why you get "Permission denied" — see [Understanding Your Permissions](../day_one/permissions.md) in Day One.

New team member starting Monday. They need access to the database logs but not the application secrets. The monitoring service needs to run as its own user so a compromise doesn't give an attacker root. The DevOps team needs a shared directory where everyone can write but only their own files.

Every one of these situations comes down to user and group management. It's one of the most routine tasks in Linux administration — and one where a mistake (like forgetting the `-a` flag in `usermod`) can silently remove access and cause a production incident.

---

## Where You've Seen This

If you've worked with Active Directory, the mental model transfers directly. AD has users, security groups, and service accounts — so does Linux. The mechanics are different (command line vs. GUI, local files vs. LDAP) but the concepts are identical:

| Active Directory | Linux Equivalent |
|-----------------|-----------------|
| User account | User account (`/etc/passwd`) |
| Security group | Group (`/etc/group`) |
| Service account | System account (UID < 1000, `nologin` shell) |
| Group membership | Secondary groups (`usermod -aG`) |
| Disable account | Lock account (`usermod -L`) |
| Password policy | Password aging (`chage`) |

One key difference: on Linux, every user has a primary group (set at creation) plus any number of secondary groups. Group membership determines file access, which tool you can run (`docker`, `sudo`), and what directories you can enter. Getting group membership wrong is the most common access problem you'll troubleshoot.

!!! tip "useradd vs adduser"
    On Debian and Ubuntu, `adduser` is a higher-level interactive wrapper that prompts for information and sets up home directories with sensible defaults. `useradd` is the lower-level command that works identically on all distributions — RHEL, Ubuntu, Debian, Arch. For scripting, cross-distro work, or if you're on RHEL/Fedora, always use `useradd`. For interactive Debian/Ubuntu use, `adduser` is friendlier and harder to misconfigure.

---

## How Linux Identifies Users

Linux doesn't track users by name internally — it tracks them by **UID** (User ID), a number. The username is just a human-readable alias.

``` bash title="See the Numeric IDs Behind Usernames"
id jsmith
# uid=1001(jsmith) gid=1001(jsmith) groups=1001(jsmith),1002(developers),27(sudo)
```

### The UID Ranges

| UID Range | Type | Examples |
|-----------|------|---------|
| `0` | Root | `root` — full system access |
| `1–999` | System accounts | `nginx`, `postgres`, `www-data`, `nobody` |
| `1000+` | Regular users | `jsmith`, `alice`, `bob` |

**System accounts** (UIDs 1–999) are created by packages for services to run under. They typically have no login shell and no home directory in `/home`. This isolation limits the damage from a compromised service — if nginx is exploited, the attacker gets `www-data`, not root.

---

## The Identity Files

Two files in `/etc/` define every user and group on the system.

### /etc/passwd — User Accounts

Despite the name, `/etc/passwd` doesn't contain passwords (they moved to `/etc/shadow` decades ago). It defines every user account:

``` bash title="Viewing /etc/passwd"
cat /etc/passwd | grep -E "^root|^jsmith|^www-data"
# root:x:0:0:root:/root:/bin/bash
# www-data:x:33:33:www-data:/var/www:/usr/sbin/nologin
# jsmith:x:1001:1001:John Smith:/home/jsmith:/bin/bash
```

Each line has seven colon-separated fields:

```
username : password : UID : GID : comment : home_dir : shell
jsmith   :    x     : 1001: 1001: John Smith: /home/jsmith : /bin/bash
```

| Field | Meaning |
|-------|---------|
| `username` | Login name |
| `password` | `x` means password is in `/etc/shadow` |
| `UID` | User ID number |
| `GID` | Primary group ID |
| `comment` | Full name or description (GECOS field) |
| `home_dir` | Home directory path |
| `shell` | Login shell (`/bin/bash`, `/usr/sbin/nologin`, `/bin/false`) |

**The shell field** is how you identify service accounts. `/usr/sbin/nologin` means the account exists (for file ownership, process identity) but can't be logged into interactively.

### /etc/group — Group Definitions

``` bash title="Viewing /etc/group"
cat /etc/group | grep -E "^developers|^sudo|^docker"
# sudo:x:27:jsmith,alice
# developers:x:1002:jsmith,bob,carol
# docker:x:998:jsmith
```

Each line: `group_name:password:GID:member_list`

The member list shows users who have this as a *secondary* group. A user's *primary* group is set in `/etc/passwd`.

### /etc/shadow — Password Hashes

`/etc/shadow` stores the actual password hashes, readable only by root:

``` bash title="Viewing /etc/shadow (requires root)"
sudo cat /etc/shadow | grep jsmith
# jsmith:$6$random$longhashhere...:19400:0:99999:7:::
```

Fields: `username:hash:last_changed:min_age:max_age:warn_days:inactive:expiry`

You rarely read this directly. The `passwd`, `chage`, and `usermod` commands manage it for you.

---

## Managing Users

### Creating Users

``` bash title="useradd — Create a User Account"
# Basic user with home directory
useradd -m -s /bin/bash jsmith

# With comment (full name) and specific UID
useradd -m -s /bin/bash -c "John Smith" -u 1050 jsmith

# Create a service account (no home dir, no login shell)
useradd -r -s /usr/sbin/nologin -c "My Application Service" myapp

# Set password immediately
passwd jsmith
# New password: [enter password]
# Retype new password: [confirm]
```

| Flag | Meaning |
|------|---------|
| `-m` | Create home directory at `/home/username` |
| `-s /bin/bash` | Set login shell |
| `-c "comment"` | Set comment/full name |
| `-u 1050` | Specify UID |
| `-g groupname` | Set primary group |
| `-G group1,group2` | Set supplementary groups |
| `-r` | Create a system account (UID in system range) |
| `-d /custom/home` | Set custom home directory |


### Modifying Users

``` bash title="usermod — Modify an Existing User"
# Add user to a supplementary group
usermod -aG developers jsmith     # (1)!

# Add to multiple groups
usermod -aG developers,docker jsmith

# Change the login shell
usermod -s /bin/zsh jsmith

# Change the home directory (moves files with -m)
usermod -d /opt/jsmith -m jsmith

# Lock an account (disable login)
usermod -L jsmith

# Unlock an account
usermod -U jsmith

# Set account expiry date
usermod -e 2026-12-31 jsmith
```

1. **The `-a` flag is critical.** Without `-a`, `usermod -G developers jsmith` *replaces* all supplementary groups with just `developers`, removing the user from every other group. With `-a` (append), it adds to the existing groups. Forgetting `-a` is a common mistake that causes production access issues.

!!! warning "Never Forget -a When Adding to Groups"
    `usermod -G developers jsmith` without `-a` removes `jsmith` from ALL other groups (sudo, docker, etc.) and sets `developers` as the only supplementary group. This can immediately break access and is a common cause of "why does X no longer work?" incidents.

    **Always:** `usermod -aG groupname username`

### Deleting Users

``` bash title="userdel — Remove a User Account"
# Remove the user (keep home directory)
userdel jsmith

# Remove the user AND their home directory
userdel -r jsmith

# Find files owned by the user before deleting
find / -user jsmith 2>/dev/null | head -20
```

Before deleting, check what files the user owns — especially in shared directories. After deletion, those files show as orphaned (UID only, no username) in `ls -l`.

---

## Managing Groups

``` bash title="Group Management Commands"
# Create a new group
groupadd developers

# Create with specific GID
groupadd -g 1050 developers

# Add a user to a group (same as usermod -aG)
usermod -aG developers jsmith

# Remove a user from a group
gpasswd -d jsmith developers

# Delete a group
groupdel developers

# Check group membership
groups jsmith
# jsmith : jsmith developers sudo docker

id jsmith
# uid=1001(jsmith) gid=1001(jsmith) groups=1001(jsmith),1002(developers),27(sudo),998(docker)
```

---

## Switching Users

``` bash title="Switching User Context"
# Switch to another user (requires their password)
su - jsmith          # the hyphen loads jsmith's environment (PATH, etc.)
su jsmith            # switch without loading environment (usually not what you want)

# Run a single command as another user
su - jsmith -c "ls -la ~"

# Switch to root (requires root password or sudo)
su -
sudo su -            # if you have sudo access

# Run a command as another user with sudo
sudo -u www-data cat /var/www/html/index.html
sudo -u postgres psql -c "SELECT version();"
```

**`su -` vs `su`:** Always use `su -` (with the dash). Without it, you switch user but keep your current environment — your `PATH`, variables, and working directory. With `-`, you get a proper login shell that sources the user's environment, which is almost always what you actually need.

---

## Service Accounts: A Critical Pattern

Service accounts are non-login user accounts created for applications to run under. This is a fundamental security pattern.

``` mermaid
graph TD
    A["🌐 External Request"] --> B["🔵 nginx process\n(runs as www-data)"]
    B --> C{Authorization}
    C -->|"Read web files"| D["✅ /var/www/html\nwww-data:www-data"]
    C -->|"Read app secrets"| E["🚫 /etc/myapp/secrets\nroot:root, 600"]
    C -->|"Write system files"| F["🚫 /etc/nginx.conf\nroot:root, 644"]

    style A fill:#1a202c,stroke:#cbd5e0,stroke-width:2px,color:#fff
    style B fill:#2b6cb0,stroke:#63b3ed,stroke-width:2px,color:#fff
    style D fill:#2f855a,stroke:#68d391,stroke-width:2px,color:#fff
    style E fill:#742a2a,stroke:#fc8181,stroke-width:2px,color:#fff
    style F fill:#742a2a,stroke:#fc8181,stroke-width:2px,color:#fff
```

The web server can only access what it needs. A compromise gives the attacker `www-data` privileges, not root.

``` bash title="Creating a Service Account"
# Create application service account
useradd \
  -r \                          # system account (UID < 1000)
  -s /usr/sbin/nologin \        # no interactive login
  -d /opt/myapp \               # home directory = app directory
  -c "My Application Service" \ # description
  myapp

# Create the application directory owned by the service account
mkdir -p /opt/myapp
chown myapp:myapp /opt/myapp
chmod 750 /opt/myapp

# Verify: the account can't be logged into
su - myapp
# This account is currently not available.
```

**Key service account conventions:**

- Use `-r` for system UID range (under 1000)
- Always set shell to `/usr/sbin/nologin` or `/bin/false`
- Grant only the permissions the application needs, nothing more
- Name it after the application: `nginx`, `postgres`, `myapp`

---

## Common Scenarios

=== "New Team Member Onboarding"

    A new developer needs access to: login, read application logs, use Docker.

    ``` bash title="Onboard a New Developer"
    # Create account
    useradd -m -s /bin/bash -c "Jane Developer" jdev

    # Set initial password (they'll change it on first login)
    passwd jdev

    # Add to relevant groups
    usermod -aG developers jdev    # team group
    usermod -aG docker jdev        # Docker access
    usermod -aG adm jdev           # read most log files

    # Force password change on first login
    chage -d 0 jdev

    # Verify
    id jdev
    # uid=1002(jdev) gid=1002(jdev) groups=1002(jdev),1002(developers),998(docker),4(adm)
    ```

=== "Offboarding a User"

    Developer leaving. Disable access immediately, audit their files, remove account later.

    ``` bash title="Offboard a Developer"
    # Lock account immediately (disable login without deleting)
    usermod -L jsmith
    passwd -l jsmith    # also lock the password

    # Check what's running as this user
    ps -u jsmith

    # Find files they own (review before deletion)
    find /home /opt /var -user jsmith 2>/dev/null | head -30

    # After review period, remove account and home directory
    userdel -r jsmith

    # Files now show UID only — reassign or remove
    find / -nouser 2>/dev/null | head -10
    ```

=== "Deploying an Application Service"

    New application needs to run as its own user with access to specific directories.

    ``` bash title="Set Up Application Service Account"
    # Create service account
    useradd -r -s /usr/sbin/nologin -c "Payment Service" payment-svc

    # Create required directories
    mkdir -p /opt/payment/{app,config,logs}

    # Set ownership
    chown -R payment-svc:payment-svc /opt/payment/

    # Config directory: service can read, others nothing
    chmod 750 /opt/payment/config/

    # Logs directory: service can write
    chmod 755 /opt/payment/logs/

    # Verify the service can't log in interactively
    su - payment-svc
    # This account is currently not available.
    ```

=== "Auditing User Access"

    Security audit or incident response: find out who has access to what.

    ``` bash title="User Access Audit"
    # List all user accounts that can log in
    grep -v "nologin\|/bin/false" /etc/passwd | cut -d: -f1,3,7

    # List members of the sudo/wheel group
    getent group sudo
    getent group wheel

    # Find all accounts with UID 0 (root-equivalent)
    awk -F: '$3 == 0 {print $1}' /etc/passwd

    # List users who have logged in recently
    last | head -20

    # Check account aging information
    chage -l jsmith
    ```

---

## Quick Reference

### User Commands

| Command | What It Does |
|---------|-------------|
| `useradd -m -s /bin/bash username` | Create user with home dir and bash shell |
| `useradd -r -s /usr/sbin/nologin svcname` | Create service account |
| `passwd username` | Set or change password |
| `usermod -aG groupname username` | Add user to a group (don't forget -a!) |
| `usermod -L username` | Lock account |
| `usermod -U username` | Unlock account |
| `userdel -r username` | Delete user and home directory |
| `chage -l username` | Show password aging info |
| `id username` | Show UID, GID, and groups |
| `groups username` | Show group memberships |

### Group Commands

| Command | What It Does |
|---------|-------------|
| `groupadd groupname` | Create a new group |
| `gpasswd -a username groupname` | Add user to group |
| `gpasswd -d username groupname` | Remove user from group |
| `groupdel groupname` | Delete a group |
| `getent group groupname` | Show group members |

### Key Files

| File | Contents |
|------|---------|
| `/etc/passwd` | User accounts (7-field format) |
| `/etc/shadow` | Password hashes and aging (root only) |
| `/etc/group` | Group definitions and memberships |
| `/etc/gshadow` | Group passwords and admin (rare) |
| `/etc/skel/` | Template files copied to new home directories |

---

## Practice Exercises

??? question "Exercise 1: Create a Developer Account"
    Create a user account for `alice` with:

    - Full name: "Alice Developer"
    - Bash shell
    - Member of the `developers` group (create it if needed)
    - Forced password change on first login

    ??? tip "Solution"
        ``` bash title="Create Alice's Account"
        # Create the group if it doesn't exist
        groupadd developers 2>/dev/null || true

        # Create Alice's account
        useradd -m -s /bin/bash -c "Alice Developer" alice

        # Set a temporary password
        passwd alice

        # Add to developers group
        usermod -aG developers alice

        # Force password change on first login
        chage -d 0 alice

        # Verify
        id alice
        ```

??? question "Exercise 2: Create a Service Account"
    Create a service account for an application called `webapp`:

    - No interactive login
    - Home directory at `/opt/webapp`
    - System account (UID under 1000)

    ??? tip "Solution"
        ``` bash title="Create webapp Service Account"
        useradd -r -s /usr/sbin/nologin -d /opt/webapp -c "Web Application Service" webapp

        # Create the home directory (useradd -r doesn't create it by default)
        mkdir -p /opt/webapp
        chown webapp:webapp /opt/webapp

        # Verify it can't log in
        su - webapp
        # This account is currently not available.

        # Check the entry in /etc/passwd
        grep webapp /etc/passwd
        # webapp:x:985:985:Web Application Service:/opt/webapp:/usr/sbin/nologin
        ```

??? question "Exercise 3: The usermod -aG Gotcha"
    User `bob` is in these groups: `bob`, `developers`, `docker`.

    Someone runs `usermod -G sudo bob`.

    What groups is `bob` in now? What should they have run instead?

    ??? tip "Solution"
        After `usermod -G sudo bob` (without `-a`):

        - **`bob` is now in:** `bob`, `sudo`
        - **Removed from:** `developers`, `docker`

        The `-G` flag *replaces* all supplementary groups. Without `-a`, it's destructive.

        What they should have run:
        ``` bash title="Correct: Add to sudo Without Removing Other Groups"
        usermod -aG sudo bob
        # Now bob is in: bob, developers, docker, sudo
        ```

---

## Quick Recap

- **UIDs:** `0` = root, `1–999` = system accounts, `1000+` = regular users
- **`/etc/passwd`** — 7-field file defining every account; shell field determines login ability
- **`useradd -m -s /bin/bash`** — create a regular user; `useradd -r -s /usr/sbin/nologin` for service accounts
- **`usermod -aG group user`** — the `-a` is mandatory; without it you remove all other groups
- **Service accounts** run applications in isolation — each service gets its own UID with minimum required permissions
- **Locking vs deleting** — `usermod -L` disables login without deleting; use this first when offboarding, delete later after review

---

## Further Reading

### Command References

- `man useradd` — user creation options and defaults
- `man usermod` — account modification reference
- `man passwd` — password management options
- `man chage` — password aging configuration
- `man su` — switching user context
- `man getent` — query the system databases (passwd, group, etc.)

### Deep Dives

- [Red Hat: Managing Users and Groups](https://www.redhat.com/sysadmin/linux-user-account-management) — enterprise user management guide
- [Linux Documentation Project: User Administration](https://tldp.org/LDP/lame/LAME/linux-admin-made-easy/users-and-groups.html) — classic Linux admin reference
- [Arch Wiki: Users and Groups](https://wiki.archlinux.org/title/Users_and_groups) — comprehensive user management reference

### Official Documentation

- [Red Hat: Managing Users and Groups](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/configuring_basic_system_settings/managing-users-and-groups_configuring-basic-system-settings) — RHEL administration guide
- [Ubuntu: User Management](https://ubuntu.com/server/docs/security-users) — Ubuntu server user management

---

## What's Next?

You can manage who exists on the system and what groups they belong to. The next essential skill is connecting commands together — using pipes and redirection to build powerful one-liners that process data without writing a single script.

Head to **[Pipes and Redirection](pipes_and_redirection.md)** to learn how to chain commands into data pipelines, redirect output to files, and combine these patterns into the kind of one-liners that every sysadmin uses daily.
