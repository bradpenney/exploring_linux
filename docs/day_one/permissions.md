# Understanding Your Permissions

You're logged in, you've oriented yourself, and now you're wondering: *What am I actually allowed to do on this server?*

This is a crucial question. Enterprise servers have strict access controls for good reason — one wrong command with elevated privileges can bring down production. Before you start working, you need to understand your permission level.

**Let's figure out what powers you have (and don't have).**

---

## The Three Permission Levels

On most servers, users fall into one of three categories:

| Level | What You Can Do | Typical Users |
|-------|----------------|---------------|
| **Regular User** | Only your own files, limited system access | Most developers |
| **Sudo User** | Elevate to root for specific tasks | Senior devs, junior admins |
| **Root** | Everything. No limits. | Admins only (rarely used directly) |

Let's figure out which one you are.

---

## Check Your Groups

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

---

## Can You Sudo?

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

---

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

To understand why, check the file's permissions:

``` bash title="Check File Permissions"
ls -la /etc/nginx/nginx.conf
# -rw-r----- 1 root nginx 2488 Jan 10 15:30 /etc/nginx/nginx.conf
```

Breaking this down:

```
-rw-r----- 1 root nginx 2488 Jan 10 15:30 /etc/nginx/nginx.conf
│└┬┘└┬┘└┬┘   └─┬┘ └─┬─┘
│ │  │  │      │    └── Group owner: nginx
│ │  │  │      └─────── File owner: root
│ │  │  └────────────── Others: no access (---)
│ │  └───────────────── Group: read only (r--)
│ └──────────────────── Owner: read+write (rw-)
└────────────────────── File type: regular file (-)
```

**Translation:** Only root can write to this file. The nginx group can read it. Everyone else (including you) is blocked.

### Your Options When Blocked

1. **You need to read it:** Ask someone to add you to the right group, or use sudo if you have it
2. **You need to edit it:** You almost certainly need sudo (or shouldn't be editing it)
3. **You're just exploring:** Move on, find files you CAN read

---

## Finding Files You CAN Access

Instead of hitting permission walls, find what's readable:

``` bash title="Find Readable Log Files"
find /var/log -type f -readable 2>/dev/null | head -20
```

``` bash title="Find Readable Config Files"
find /etc -type f -readable 2>/dev/null | head -20
```

This shows you what's already available to your user without needing elevated access.

---

## Using Sudo Safely

If you have sudo access, use it carefully:

### Run a Single Command as Root

``` bash title="Sudo Single Command"
sudo systemctl status nginx
```

You'll be prompted for YOUR password (not root's password), then the command runs with root privileges.

### Common Sudo Commands

``` bash title="View Protected Logs"
sudo tail -100 /var/log/secure
```

``` bash title="Restart a Service"
sudo systemctl restart nginx
```

``` bash title="Edit Protected Config"
sudo vim /etc/nginx/nginx.conf
```

### Check Without Modifying

Not sure if your sudo command will work? Test with a harmless command first:

``` bash title="Test Sudo Access"
sudo whoami
# root
```

If that works, you have sudo. If not, you'll see an error or be asked to provide justification.

!!! danger "Sudo Is Not a Toy"
    Every command you run with `sudo` executes as root. A typo can be catastrophic:

    - `sudo rm -rf /` — Deletes everything. Entire server gone.
    - `sudo chmod -R 777 /` — Security nightmare.
    - `sudo dd if=/dev/zero of=/dev/sda` — Destroys the disk.

    Always double-check before pressing Enter on any sudo command.

---

## Understanding Service Accounts

Sometimes you'll see processes running as special users:

``` bash title="Check Who Runs What"
ps aux | head -20
```

```
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.1 169836 13284 ?        Ss   Dec01   0:25 /usr/lib/systemd
nginx     1234  0.0  0.2  45678 23456 ?        S    Dec01   0:00 nginx: worker
mysql     2345  0.5  5.0 123456 98765 ?        Sl   Dec01  45:00 /usr/sbin/mysqld
```

**Service accounts like `nginx`, `mysql`, `www-data`:**

- Are not meant for human login
- Own files related to their service
- Have limited permissions by design
- Help contain damage if that service is compromised

You don't need to worry about these accounts, just understand why they exist.

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

## Quick Recap

**Find your access level:**

1. `groups` — What groups am I in?
2. `sudo -l` — What can I sudo?
3. `ls -la` — Who owns this file?

**Permission denied?**

- Check file ownership with `ls -la`
- See if sudo helps (if you have it)
- Find files you CAN access instead
- Ask for access if you legitimately need it

**Using sudo?**

- Run the minimum command needed
- Double-check before pressing Enter
- Never run commands you don't understand

---

## What's Next?

Now that you understand your permission level, let's learn how to explore the server safely without accidentally changing anything. Head to [Safe Exploration](safe_exploration.md) to learn read-only exploration techniques.

!!! tip "Bookmark Your Access Level"
    First time on a server, run `id` and `sudo -l` and make a mental note. Knowing your access level prevents frustration and keeps you from accidentally trying things that won't work.
