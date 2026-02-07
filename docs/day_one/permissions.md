# Understanding Your Permissions

You're [logged in](getting_access.md), you've [oriented yourself](orientation.md), and now you're wondering: *What am I actually allowed to do on this server?*

This is a crucial question. Enterprise servers have strict access controls for good reason — one wrong command with elevated privileges can bring down production. Before you start working, you need to understand your permission level.

**Let's figure out what powers you have (and don't have).**

!!! tip "Part of Day One"
    This article is part of the [Day One series](overview.md) - essential skills for your first day on a Linux server.

---

## Understanding Linux Permission Hierarchy

Here's how Linux organizes user permissions from most to least powerful:

``` mermaid
graph TD
    A["🔴 Root User (uid=0)<br/><br/>Full System Access<br/>No Restrictions<br/>Can Break Everything"]
    B["🟡 Regular User + Sudo<br/><br/>Temporarily Become Root<br/>For Specific Commands<br/>Requires Authentication"]
    C["🟢 Regular User<br/><br/>Own Files Only<br/>Limited System Access<br/>Safest Default"]

    style A fill:#c92a2a,stroke:#ff6b6b,stroke-width:3px,color:#fff
    style B fill:#d97706,stroke:#fbbf24,stroke-width:3px,color:#fff
    style C fill:#2f9e44,stroke:#51cf66,stroke-width:3px,color:#fff
```

**You are ONE of these.** You don't "escalate" - you either have an identity (Regular or Root) and may have sudo permissions that let you temporarily run commands as root.

---

## The Three Permission Levels

On most servers, users fall into one of three categories:

| Level | What You Can Do | Typical Users |
|-------|----------------|---------------|
| **Regular User** | Only your own files, limited system access | Most developers |
| **Sudo User** | Elevate to root for specific tasks | Senior devs, junior admins |
| **Root** | Everything. No limits. | Admins only (rarely used directly) |

But before we figure out which one you are, you need to understand how Linux actually controls access to files.

---

## Understanding File Permissions (rwx)

Every file and directory on Linux has permissions that determine who can read, write, or execute it. This is the foundation of Linux security.

### Why This Matters

Understanding file permissions explains:

- Why you can read some files but not others
- Why `cd /root` fails but `cd /home` works
- Why some scripts won't run even though you can read them (missing execute permission)
- Why you need `sudo` to edit system files

Let's see this in action:

``` bash title="Check Permissions on Common Locations"
ls -ld /root
# drwx------ 5 root root 4096 Jan 15 10:00 /root
# Only root can access

ls -ld /home
# drwxr-xr-x 5 root root 4096 Jan 15 10:00 /home
# Everyone can list, only root can create users

ls -la /etc/shadow
# -rw-r----- 1 root shadow 1234 Jan 15 10:00 /etc/shadow
# Root can read/write, shadow group can read, others blocked
```

**For Day One:** You don't need to master all the details below. Just understand that those weird letter codes (`rwxr-xr-x`) control who can access what. Explore the tabs if you're curious.

### The Details (Optional for Day One)

=== ":material-information: The Basics"

    Every file has three pieces of permission information:

    1. **Owner** - The user who owns the file
    2. **Group** - The group that owns the file
    3. **Permissions** - What the owner, group, and others can do

    Check any file's permissions:

    ``` bash title="View File Permissions"
    ls -la /etc/hosts
    # -rw-r--r-- 1 root root 220 Jan 15 10:00 /etc/hosts
    ```

    Let's decode that permission string:

    ```
    -rw-r--r-- 1 root root 220 Jan 15 10:00 /etc/hosts
    │└┬┘└┬┘└┬┘   └─┬┘ └─┬─┘
    │ │  │  │      │    └── Group owner: root
    │ │  │  │      └─────── File owner: root
    │ │  │  └────────────── Others: read only (r--)
    │ │  └───────────────── Group: read only (r--)
    │ └──────────────────── Owner: read+write (rw-)
    └────────────────────── File type: regular file (-)
    ```

=== ":material-key: Permission Types"

    Each position can have one of three permissions:

    | Permission | Symbol | For Files | For Directories |
    |------------|--------|-----------|-----------------|
    | **Read** | `r` | View file contents | List directory contents |
    | **Write** | `w` | Modify file | Create/delete files inside |
    | **Execute** | `x` | Run as program/script | Enter the directory (cd into it) |
    | **None** | `-` | No access | No access |

    Permissions are shown in groups of three: **owner**, **group**, **others**

    ```
    rwxr-xr--
    │││││││││
    │││└┬┘└┬┘
    │││ │  └─── Others: read only (r--)
    │││ └────── Group: read + execute (r-x)
    │└┴──────── Owner: read + write + execute (rwx)
    └────────── File type (d=directory, -=file, l=link)
    ```

=== ":material-file-code: Common Patterns"

    **Files:**

    ```
    -rw-r--r--  (644)  # Config files - owner writes, others read
    -rw-------  (600)  # Private files like SSH keys
    -rwxr-xr-x  (755)  # Executable scripts
    ```

    **Directories:**

    ```
    drwxr-xr-x  (755)  # Standard directory
    drwx------  (700)  # Private directory (like home directories)
    drwxrwxr-x  (775)  # Shared directory
    ```

    !!! warning "Avoid 777 Permissions in Enterprise"
        Files with `-rwxrwxrwx` (777) permissions mean **anyone can read, write, and execute**. This is a major security risk.

        **In enterprise environments:**

        - Security scanning tools will flag 777 files
        - Compliance audits will require remediation
        - You may be asked to fix these immediately

        **Never set 777 permissions on production systems.** If you see them, it's usually a sign of improper configuration or a security issue that needs attention.

=== ":material-check-circle: How Linux Checks"

    **Critical concept:** Linux checks in order and stops at the first match.

    1. **Are you the owner?** → Use owner permissions (stop checking)
    2. **Are you in the file's group?** → Use group permissions (stop checking)
    3. **Else** → Use "others" permissions

    **Example:**

    ```
    -rw-r----- 1 alice developers 1024 Jan 15 10:00 report.txt
    ```

    - **alice** (owner): Can read and write (`rw-`)
    - **bob** (in developers group): Can only read (`r--`)
    - **charlie** (not owner, not in group): No access (`---`)

    **Important:** Even if alice is ALSO in the developers group, she gets owner permissions (`rw-`), not group permissions. First match wins.

---

## How to Check Your Permission Level

Now that you understand how file permissions work, let's figure out what level of access YOU have on this server.

Use these commands to determine what access you have on the server:

=== ":material-account-group: Check Your Groups"

    Your group memberships determine a lot about what you can do:

    ``` bash title="List Your Groups"
    groups
    # jsmith sudo docker developers
    ```

    Or with more detail:

    ``` bash title="Full Group Information"
    id
    # uid=1001(jsmith) gid=1001(jsmith) groups=1001(jsmith),27(sudo),998(docker),1002(developers)
    ```

    **Key groups to look for:**

    | Group | What It Means |
    |-------|--------------|
    | `sudo` or `wheel` | You can run commands as root |
    | `docker` | You can run Docker commands without sudo |
    | `www-data` | Web server access (read/write web files) |
    | `adm` | Can read most log files |
    | Custom groups | Team-specific access (ask your team what they mean) |

    !!! tip "No sudo/wheel group?"
        If you don't see `sudo` or `wheel` in your groups, you're a regular user without root access. That's normal for many developer accounts — it's a security feature, not a limitation of your skills.

=== ":material-shield-account: Check Sudo Access"

    The `sudo` command lets you run commands as root (the superuser). But having the `sudo` group doesn't always mean you can do everything.

    **Check what sudo lets you do:**

    ``` bash title="Check Sudo Permissions"
    sudo -l
    ```

    You might see:

    ```
    User jsmith may run the following commands on prod-web-01:
        (ALL : ALL) ALL
    ```

    This means you can run **any command** as root. Full power.

    Or you might see something more restrictive:

    ```
    User jsmith may run the following commands on prod-web-01:
        (root) /usr/bin/systemctl restart nginx
        (root) /usr/bin/tail /var/log/nginx/*
    ```

    This means you can only restart nginx and read its logs — nothing else with sudo.

    **Or you might see:**

    ```
    Sorry, user jsmith may not run sudo on prod-web-01.
    ```

    No sudo for you. You're working with regular user permissions only.

## What "Permission Denied" Actually Means

You'll inevitably see this error:

```
-bash: /etc/nginx/nginx.conf: Permission denied
```

Or:

```
cat: /var/log/secure: Permission denied
```

**This isn't a bug — it's Linux protecting the system.**

Now you can use what you learned about file permissions to understand why. Check the file's permissions:

``` bash title="Check File Permissions"
ls -la /etc/nginx/nginx.conf
# -rw-r----- 1 root nginx 2488 Jan 10 15:30 /etc/nginx/nginx.conf
```

Reading the permission string: `-rw-r-----`

- **Owner (root):** read + write (`rw-`)
- **Group (nginx):** read only (`r--`)
- **Others (you):** no access (`---`)

You're not root, and you're probably not in the nginx group. Linux checked the permissions and blocked you.

### Your Options When Blocked

1. **You need to read it:** Ask someone to add you to the right group, or use sudo if you have it
2. **You need to edit it:** You almost certainly need sudo (or shouldn't be editing it)
3. **You're just exploring:** Move on, find files you CAN read

---

## When to Ask for More Access

You'll sometimes need permissions you don't have. Here's the right approach:

**DO:**

- Ask your team lead or sysadmin politely
- Explain what you're trying to accomplish
- Request the minimum access you need
- Accept "no" gracefully — there may be good reasons

**DON'T:**

- Try to hack around permission limits
- Ask for root access when you need to read one log file
- Get frustrated — permissions protect the system (and you)

**Example request:**

> "Hey, I need to read the nginx error logs to debug the API timeout issue. Can I get added to the `adm` group, or is there another way to access `/var/log/nginx/error.log`?"

Much better than "I need root access."

### Enterprise Access Processes

In most companies, getting elevated access follows a formal process:

=== ":material-server: Standard Environments"

    **Typical sudo access for dev/staging servers:**

    | Aspect | What to Expect |
    |--------|---------------|
    | **Scope** | Specific servers or server groups (not blanket access) |
    | **Approval** | Manager or team lead approval required |
    | **Duration** | Time-limited, renewed periodically (quarterly/annually) |
    | **Auditing** | All sudo commands logged and reviewable |

    **Bottom line:** You'll have reasonable access, but it's controlled and monitored.

=== ":material-shield-lock: Production Environments"

    **Stricter controls for production systems:**

    | Feature | How It Works |
    |---------|-------------|
    | **ID Checkout** | Check out privileged IDs (not permanent sudo) |
    | **Justification** | Must provide ticket number or business reason |
    | **Time-Boxed** | Access expires after hours, not days |
    | **Multiple Approvers** | May need manager + security team approval |
    | **Auto-Revocation** | Access automatically removed when time expires |

    **Bottom line:** Production access is heavily restricted. Plan ahead.

=== ":material-clipboard-check: Example Workflow"

    **Typical enterprise access request:**

    ``` mermaid
    graph TD
        A[Submit Access Request<br/>ServiceNow, Jira, etc.] --> B[Provide Justification<br/>Business reason + server list]
        B --> C[Manager Approval<br/>Direct manager reviews]
        C --> D[Security Review<br/>Security team validates]
        D --> E[Access Granted<br/>Limited scope, time-limited]
        E --> F[Monitoring Active<br/>All actions logged & auditable]

        style A fill:#2b6cb0,stroke:#2c5282,color:#fff
        style B fill:#2b6cb0,stroke:#2c5282,color:#fff
        style C fill:#d97706,stroke:#b45309,color:#fff
        style D fill:#d97706,stroke:#b45309,color:#fff
        style E fill:#2f855a,stroke:#276749,color:#fff
        style F fill:#1a202c,stroke:#2d3748,color:#fff
    ```

    **Timeline:** Expect 1-3 days for standard access, 3-7 days for production.

    !!! tip "Plan Ahead"
        Don't wait until you urgently need access. Request it early in your project timeline, especially for production systems.

---

## The Permissions Cheat Sheet

| Task | Check With | What You Need |
|------|-----------|---------------|
| Read a file | `ls -la filename` | Read (r) permission or sudo |
| Edit a file | `ls -la filename` | Write (w) permission or sudo |
| Run a script | `ls -la script.sh` | Execute (x) permission |
| Access a directory | `ls -la dirname` | Execute (x) on directory |
| Restart service | `sudo -l` | Sudo with service permission |
| Read protected logs | `sudo -l` or group membership | `adm` group or sudo |

---

## Practice Exercises

Now that you understand permissions, try these hands-on exercises to build confidence:

??? question "Exercise 1: Check Your Access Level"
    Run the commands to determine your permission level on the server. Find out:

    1. What is your username?
    2. What groups are you in?
    3. Can you use sudo? If so, what can you sudo?

    **Hint:** Use `whoami`, `groups`, `id`, and `sudo -l`.

    ??? tip "Solution"
        ``` bash title="Check Your Identity and Access"
        # Check your username
        whoami

        # Check your groups
        groups

        # Get detailed ID information
        id

        # Check sudo privileges
        sudo -l
        ```

        **What to note:**

        - Your username from `whoami`
        - Whether you see `sudo` or `wheel` in your groups
        - What the `sudo -l` command shows (full access, limited access, or no access)

??? question "Exercise 2: Investigate a Permission Denied Error"
    Try to read a protected file (this is safe, it will just tell you "no"):

    ``` bash title="Try Reading a Protected File"
    cat /etc/shadow
    ```

    You'll get "Permission denied." Now investigate why:

    1. Check the file's permissions with `ls -la /etc/shadow`
    2. Who owns the file?
    3. What permissions does the owner have?
    4. What permissions do you (as "others") have?

    **Challenge:** Can you read it with sudo (if you have sudo access)?

    ??? tip "Solution"
        ``` bash title="Investigate the Permissions"
        # Try to read (will fail)
        cat /etc/shadow
        # cat: /etc/shadow: Permission denied

        # Check why
        ls -la /etc/shadow
        # -rw-r----- 1 root shadow 1234 Jan 15 10:00 /etc/shadow
        ```

        **Analysis:**

        - Owner: `root` (read+write)
        - Group: `shadow` (read only)
        - Others: no permissions (---)
        - You're not root and not in the shadow group, so you're blocked

        **With sudo (if available):**

        ``` bash title="Read with Sudo"
        sudo cat /etc/shadow
        # root:$6$random_hash...:18000:0:99999:7:::
        ```

        **Warning:** The `/etc/shadow` file contains password hashes. In production, only read this if you have a legitimate reason.

---

## Quick Recap

| Scenario | What to Do | Commands |
|----------|-----------|----------|
| **First time on server** | Find your access level | `groups` - What groups am I in?<br/>`sudo -l` - What can I sudo?<br/>`id` - Full identity info |
| **Permission denied error** | Investigate why | `ls -la filename` - Check ownership<br/>Try sudo if you have it<br/>Ask for access if needed |
| **Using sudo** | Use carefully | Run minimum command needed<br/>Double-check before Enter<br/>Never run unknown commands |
| **Need more access** | Follow process | Ask team lead politely<br/>Explain what you need<br/>Request minimum required |

---

## What's Next?

Now that you understand your permission level, you're ready to explore the server safely. The next article in the Day One series will cover safe exploration techniques—how to look around without accidentally changing anything.

**Coming soon:** Safe Exploration - Read-only exploration techniques

For now, head back to the [Day One Overview](overview.md) to see what's available and track upcoming articles.

!!! tip "Bookmark Your Access Level"
    First time on a server, run `id` and `sudo -l` and make a mental note. Knowing your access level prevents frustration and keeps you from accidentally trying things that won't work.

---

## Further Reading

### Command References

- `man sudo` - Complete sudo documentation with all options and configuration
- `man id` - Display user and group identity information
- `man groups` - Show group memberships
- `man chmod` - Change file permissions (covered in depth in Level 3)
- `man chown` - Change file ownership
- `man ls` - List directory contents (the `-l` flag shows permissions)
- `man find` - Search for files (the `-readable`, `-writable` flags filter by access)

### Deep Dives

- [Sudo Manual](https://www.sudo.ws/about/intro/) - Official sudo project documentation
- [Understanding Linux File Permissions](https://www.redhat.com/sysadmin/linux-file-permissions-explained) - Red Hat's comprehensive guide
- [Principle of Least Privilege](https://en.wikipedia.org/wiki/Principle_of_least_privilege) - Why systems limit access by default

### Official Documentation

- [Red Hat: Managing sudo access](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/configuring_basic_system_settings/managing-sudo-access_configuring-basic-system-settings) - Enterprise Linux sudo configuration
- [Ubuntu Server Guide: User Management](https://ubuntu.com/server/docs/security-users) - Ubuntu-specific user and permission guidance
- [Linux Documentation Project: Users and Groups](https://tldp.org/LDP/lame/LAME/linux-admin-made-easy/users-and-groups.html) - Classic reference on Linux user management

### Security Considerations

- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks) - Industry-standard security configurations (includes sudo hardening)
- [NIST: Least Privilege](https://csrc.nist.gov/glossary/term/least_privilege) - Official definition and security guidance
