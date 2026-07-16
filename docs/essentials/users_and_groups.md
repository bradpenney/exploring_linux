---
date: "2026-04-04 18:47"
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
useradd -m -s /bin/bash jsmith                                     # (1)!
useradd -m -s /bin/bash -c "John Smith" -u 1050 jsmith             # (2)!
useradd -r -s /usr/sbin/nologin -c "My Application Service" myapp   # (3)!
passwd jsmith                                                      # (4)!
# New password: [enter password]
# Retype new password: [confirm]
```

1. Basic user with a home directory.
2. With a comment (full name) and a specific UID.
3. A service account — no home directory, no login shell.
4. Set the password immediately.

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
usermod -aG developers jsmith         # (1)!
usermod -aG developers,docker jsmith  # (2)!
usermod -s /bin/zsh jsmith            # (3)!
usermod -d /opt/jsmith -m jsmith      # (4)!
usermod -L jsmith                     # (5)!
usermod -U jsmith                     # (6)!
usermod -e 2026-12-31 jsmith          # (7)!
```

1. Add a user to a supplementary group. **The `-a` (append) flag is critical** — without it, `usermod -G developers jsmith` *replaces* all supplementary groups with just `developers`, removing the user from every other group. Forgetting `-a` is a common cause of production access incidents.
2. Add to multiple groups at once.
3. Change the login shell.
4. Change the home directory (`-m` moves the existing files).
5. Lock an account (disable login).
6. Unlock an account.
7. Set an account expiry date.

!!! warning "Never Forget -a When Adding to Groups"
    `usermod -G developers jsmith` without `-a` removes `jsmith` from ALL other groups (sudo, docker, etc.) and sets `developers` as the only supplementary group. This can immediately break access and is a common cause of "why does X no longer work?" incidents.

    **Always:** `usermod -aG groupname username`

### Deleting Users

``` bash title="userdel — Remove a User Account"
userdel jsmith                              # (1)!
userdel -r jsmith                           # (2)!
find / -user jsmith 2>/dev/null | head -20  # (3)!
```

1. Remove the user (keep their home directory).
2. Remove the user **and** their home directory.
3. Find files owned by the user before deleting — orphaned files show a bare UID afterward.

Before deleting, check what files the user owns — especially in shared directories. After deletion, those files show as orphaned (UID only, no username) in `ls -l`.

---

## Managing Groups

``` bash title="Group Management Commands"
groupadd developers              # (1)!
groupadd -g 1050 developers      # (2)!
usermod -aG developers jsmith    # (3)!
gpasswd -d jsmith developers     # (4)!
groupdel developers              # (5)!
groups jsmith                    # (6)!
# jsmith : jsmith developers sudo docker

id jsmith                        # (7)!
# uid=1001(jsmith) gid=1001(jsmith) groups=1001(jsmith),1002(developers),27(sudo),998(docker)
```

1. Create a new group.
2. Create with a specific GID.
3. Add a user to a group (same as `usermod -aG`).
4. Remove a user from a group.
5. Delete a group.
6. Check group membership.
7. The fuller view — numeric IDs alongside every group.

---

## Switching Users

``` bash title="Switching User Context"
su - jsmith                                      # (1)!
su jsmith                                        # (2)!
su - jsmith -c "ls -la ~"                        # (3)!
su -                                             # (4)!
sudo su -                                        # (5)!
sudo -u www-data cat /var/www/html/index.html    # (6)!
sudo -u postgres psql -c "SELECT version();"     # (7)!
```

1. Switch to another user (requires their password). The hyphen loads jsmith's environment — `PATH`, variables, working directory.
2. Switch *without* loading their environment — usually not what you want.
3. Run a single command as another user.
4. Switch to root (requires the root password, or sudo).
5. Become root via sudo, if you have sudo access.
6. Run a command as another user with sudo.
7. Another `sudo -u` example — run `psql` as the postgres user.

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
useradd \
  -r \                          # (1)!
  -s /usr/sbin/nologin \        # (2)!
  -d /opt/myapp \               # (3)!
  -c "My Application Service" \ # (4)!
  myapp

mkdir -p /opt/myapp             # (5)!
chown myapp:myapp /opt/myapp
chmod 750 /opt/myapp

su - myapp                      # (6)!
# This account is currently not available.
```

1. System account — UID in the system range (< 1000).
2. No interactive login.
3. Home directory = the application directory.
4. Description / comment.
5. Create the application directory, owned by the service account.
6. Verify the account can't be logged into.

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
    useradd -m -s /bin/bash -c "Jane Developer" jdev   # (1)!
    passwd jdev                                        # (2)!
    usermod -aG developers jdev                        # (3)!
    usermod -aG docker jdev                            # (4)!
    usermod -aG adm jdev                               # (5)!
    chage -d 0 jdev                                    # (6)!
    id jdev                                            # (7)!
    # uid=1002(jdev) gid=1002(jdev) groups=1002(jdev),1002(developers),998(docker),4(adm)
    ```

    1. Create the account.
    2. Set an initial password — they'll change it on first login.
    3. Add to the team group.
    4. Grant Docker access.
    5. Let them read most log files (the `adm` group).
    6. Force a password change on first login.
    7. Verify.

=== "Offboarding a User"

    Developer leaving. Disable access immediately, audit their files, remove account later.

    ``` bash title="Offboard a Developer"
    usermod -L jsmith                                          # (1)!
    passwd -l jsmith                                           # (2)!
    ps -u jsmith                                               # (3)!
    find /home /opt /var -user jsmith 2>/dev/null | head -30   # (4)!
    userdel -r jsmith                                          # (5)!
    find / -nouser 2>/dev/null | head -10                      # (6)!
    ```

    1. Lock the account immediately — disables login without deleting.
    2. Also lock the password.
    3. Check what's currently running as this user.
    4. Find files they own — review before deletion.
    5. After the review period, remove the account and home directory.
    6. Orphaned files now show a UID only — reassign or remove them.

=== "Deploying an Application Service"

    New application needs to run as its own user with access to specific directories.

    ``` bash title="Set Up Application Service Account"
    useradd -r -s /usr/sbin/nologin -c "Payment Service" payment-svc   # (1)!

    mkdir -p /opt/payment/{app,config,logs}   # (2)!

    chown -R payment-svc:payment-svc /opt/payment/   # (3)!

    chmod 750 /opt/payment/config/   # (4)!

    chmod 755 /opt/payment/logs/   # (5)!

    su - payment-svc   # (6)!
    # This account is currently not available.
    ```

    1. Create the service account.
    2. Create the required directories.
    3. Set ownership.
    4. Config directory: service can read, others nothing.
    5. Logs directory: service can write.
    6. Verify the service can't log in interactively.

=== "Auditing User Access"

    Security audit or incident response: find out who has access to what.

    ``` bash title="User Access Audit"
    grep -v "nologin\|/bin/false" /etc/passwd | cut -d: -f1,3,7   # (1)!

    getent group sudo    # (2)!
    getent group wheel

    awk -F: '$3 == 0 {print $1}' /etc/passwd   # (3)!

    last | head -20   # (4)!

    chage -l jsmith   # (5)!
    ```

    1. List all user accounts that can log in.
    2. List members of the sudo/wheel group.
    3. Find all accounts with UID 0 (root-equivalent).
    4. List users who have logged in recently.
    5. Check account aging information.

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
        groupadd developers 2>/dev/null || true             # (1)!
        useradd -m -s /bin/bash -c "Alice Developer" alice   # (2)!
        passwd alice                                        # (3)!
        usermod -aG developers alice                        # (4)!
        chage -d 0 alice                                    # (5)!
        id alice                                            # (6)!
        ```

        1. Create the group if it doesn't already exist.
        2. Create Alice's account.
        3. Set a temporary password.
        4. Add to the developers group.
        5. Force a password change on first login.
        6. Verify.

??? question "Exercise 2: Create a Service Account"
    Create a service account for an application called `webapp`:

    - No interactive login
    - Home directory at `/opt/webapp`
    - System account (UID under 1000)

    ??? tip "Solution"
        ``` bash title="Create webapp Service Account"
        useradd -r -s /usr/sbin/nologin -d /opt/webapp -c "Web Application Service" webapp   # (1)!
        mkdir -p /opt/webapp                  # (2)!
        chown webapp:webapp /opt/webapp
        su - webapp                           # (3)!
        # This account is currently not available.
        grep webapp /etc/passwd               # (4)!
        # webapp:x:985:985:Web Application Service:/opt/webapp:/usr/sbin/nologin
        ```

        1. Create the system service account — no login shell, home at `/opt/webapp`.
        2. Create the home directory — `useradd -r` doesn't create it by default.
        3. Verify it can't log in.
        4. Check the entry in `/etc/passwd`.

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

## What's Next?

You can manage who exists on the system and what groups they belong to. The next essential skill is connecting commands together — using pipes and redirection to build powerful one-liners that process data without writing a single script.

Head to **[Pipes and Redirection](pipes_and_redirection.md)** to learn how to chain commands into data pipelines, redirect output to files, and combine these patterns into the kind of one-liners that every sysadmin uses daily.

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

