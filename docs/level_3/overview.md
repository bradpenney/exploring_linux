# Level 3: Processes & Permissions

!!! quote "Time to see what's really happening under the hood"

## Welcome to Level 3

You can navigate, manage files, and search like a pro. But Linux is more than files - it's about running processes, users with different privileges, and a sophisticated permissions system that controls who can do what.

**This level lifts the hood.** You'll learn what's actually running, how to control it, and how Linux decides whether you're allowed to do something.

## What You'll Master

Understanding processes and permissions is essential for system administration and troubleshooting:

- **What's running** - `ps`, `top`, `htop`
- **Managing processes** - `kill`, `jobs`, `bg`, `fg`, `nice`
- **Users and groups** - `whoami`, `id`, `groups`
- **File permissions** - `chmod`, `chown`, `umask`
- **Permission troubleshooting** - "Why can't I access this file?"

## Who This Level Is For

**Perfect for:**

- Anyone who's completed Level 2
- People who've seen "permission denied" and want to understand why
- Developers who need to manage running processes
- Anyone preparing for system administration tasks

**Prerequisites:**

You should be comfortable finding files, searching content, and basic command-line navigation. If you're not there yet, complete [Level 1](../level_1/overview.md) and [Level 2](../level_2/overview.md) first.

## The Skills

Work through these to understand Linux's process and permission model:

1. **[Filesystem Hierarchy](filesystem_hierarchy.md)** - Where things live and why
2. **[Users and Groups](users_groups.md)** - whoami, id, groups
3. **[File Permissions](file_permissions.md)** - chmod, chown, understanding rwx
4. **[umask and Default Permissions](umask.md)** - How new files get their permissions
5. **[Permission Troubleshooting](permission_troubleshooting.md)** - Fixing access issues
6. **[Viewing Processes](ps_top_htop.md)** - ps, top, htop - what's running?
7. **[Managing Processes](process_control.md)** - kill, jobs, bg, fg, nice

## What's Next?

Once you understand processes and permissions, you're ready for [Level 4: System Management](../level_4/overview.md). That's where you'll learn to manage services, check system resources, work with networks, and handle archives.

## The Philosophy

**Permissions exist for a reason.** They protect the system and keep users from accidentally (or intentionally) breaking things. Understanding them means you can work confidently without constantly hitting "permission denied."

**Processes are programs in action.** That web server, that database, that script you just ran - they're all processes. Being able to see them, control them, and understand their resource usage is fundamental to working with Linux systems.

## Real-World Scenarios

These skills solve real problems:

- "This script won't run" → Permission issue? Check with `ls -la`
- "The server is slow" → Check processes with `top`, find the culprit
- "I can't edit this file" → Check ownership with `ls -l`, maybe need `sudo`
- "This process is frozen" → Find PID with `ps`, kill it with `kill`
- "Why are my new files unreadable by others?" → Check your `umask`

Understanding this level turns mysterious errors into solvable problems.

Let's peek under the hood.
