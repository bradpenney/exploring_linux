---
title: Exploring Enterprise Linux
description: Enterprise Linux from first SSH login to production mastery — built for developers who need Linux to work, and IT professionals who need to own it.
---
<img src="images/exploring_linux.png" alt="Exploring Linux" class="img-responsive-right" width="300">

# Exploring Enterprise Linux

Linux runs the infrastructure that matters — the servers, the pipelines, the containers,
the cloud. Whether you need to work on it or want to master it, this site gets you there.

## Two Tracks, Two Goals

This site serves two different people with two different relationships to Linux.

### 🏥 Day One — For developers who need Linux for their work

You write software — backend, frontend, data, whatever — and Linux is where it runs.
You're not trying to become a sysadmin. You need to get connected, stay safe, not break
anything, and get back to building.

Day One gives you exactly what you need and nothing you don't.

- [Overview](day_one/overview.md)
- [Getting Access](day_one/getting_access.md) — SSH connection and local setup
- [Orientation](day_one/orientation.md) — First 60 seconds on a new server
- [Understanding Permissions](day_one/permissions.md) — What you can and can't do
- [Safe Exploration](day_one/safe_exploration.md) — Look around without breaking things
- [Reading Logs](day_one/reading_logs.md) — Debug your application with journalctl and grep
- [Finding Documentation](day_one/finding_docs.md) — man pages, git history, and what the server tells you
- [The "Don't Do This" Guide](day_one/safety_guide.md) — Production safety rules that keep you out of trouble

### 📦⚡🎯 Essentials / Efficiency / Mastery — For IT professionals getting serious about Linux

You're a sysadmin, platform engineer, or SRE — or you're moving into one of those roles.
Maybe you've been doing Windows administration for years. Maybe you've been handed
infrastructure that runs on Linux and need to own it properly. Either way, you know IT.
You need to know Linux.

The three tracks take you from command-line fundamentals to production-grade expertise:

**📦 Essentials** — The commands and concepts every Linux professional must own cold.
The filesystem layout, permissions model, user management, process control, pipes and
redirection. The foundation everything else is built on.

- [Command Line Fundamentals](essentials/command_line_fundamentals.md) — Tab completion, history tricks, and command chaining
- [Filesystem Hierarchy](essentials/filesystem_hierarchy.md) — Where everything lives and why
- [Finding Files](essentials/finding_files.md) — find, locate, and which
- [Finding Help](essentials/finding_help.md) — man pages, tldr, and online resources
- [File Permissions](essentials/file_permissions.md) — chmod, chown, umask, SUID, SGID, sticky bit
- [Users and Groups](essentials/users_and_groups.md) — useradd, usermod, service accounts
- [Pipes and Redirection](essentials/pipes_and_redirection.md) — Build data pipelines, redirect streams
- [grep](essentials/grep.md) — Pattern matching, regex, and log analysis
- [Processes](essentials/processes.md) — ps, top, signals, job control

**⚡ Efficiency** — The daily-use tools that separate professionals who get things done:
systemd, shell scripting, package management, networking. *(Coming soon)*

**🎯 Mastery** — Production-grade Linux for engineers who own infrastructure: storage,
LVM, containers, system hardening, performance tuning. *(Coming soon)*

---

*New to Linux entirely? Start with [Day One: Overview](day_one/overview.md).*
*Coming from Windows or another IT background? Jump to [Essentials](essentials/command_line_fundamentals.md).*
