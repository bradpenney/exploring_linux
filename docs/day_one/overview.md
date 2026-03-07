---
title: Day One - Linux for Developers
description: Linux survival guide for developers — SSH, orientation, permissions, logs, documentation, and production safety rules. Get effective without becoming a sysadmin.
---

# Day One: Linux for Developers

Your code runs in production — on servers, in containers, in Kubernetes clusters. Every pod
runs on a Linux node. Every CI/CD runner is Linux underneath. The OS you're learning isn't
a prerequisite for the real work — it *is* the environment the real work lives in.

Day One closes the gap between "I use it" and "I can work in it." No hand-holding, no
sysadmin deep-dives. Just what you need to be effective.

## What You'll Be Able to Do

By the end of Day One, you'll handle these situations without hesitation:

| Situation | Skill |
|:----------|:------|
| Someone hands you SSH credentials | Connect from any machine |
| You're on an unfamiliar server | Orient yourself in under a minute |
| You're not sure what you're allowed to do | Read and work within your permissions |
| You want to explore without risk | Safe read-only reconnaissance |
| Your application is behaving strangely | Find and read the relevant logs |

## Two Starting Points

=== ":material-server-network: You have server credentials"

    Someone gave you an IP address, a username, and either a password or an SSH key.
    Maybe it's a CI/CD server, a staging environment, or a production system.

    Start with **[Getting Access](getting_access.md)** — we'll get you connected and
    oriented on a system you've never seen before.

=== ":material-laptop: You're setting up your own environment"

    You want to learn and experiment without risk to anything real. WSL2 on Windows,
    a VM in VirtualBox, or a cloud instance you control.

    Still start with **[Getting Access](getting_access.md)** — it covers local setup
    options and gets you to a working Linux terminal either way.

## The Articles

Work through these in order:

1. **[Getting Access](getting_access.md)** — Connect via SSH or set up a local Linux environment
2. **[Orientation](orientation.md)** — Where am I? What is this server? Who am I?
3. **[Understanding Permissions](permissions.md)** — What can I do here, and what's off-limits?
4. **[Safe Exploration](safe_exploration.md)** — How to look around without touching anything risky
5. **[Reading Logs](reading_logs.md)** — `tail`, `journalctl`, and `grep` for debugging your application
6. **[Finding Documentation](finding_docs.md)** — man pages, README files, git history, and what the server tells you about itself
7. **[The "Don't Do This" Guide](safety_guide.md)** — Production safety rules that will keep you out of trouble

## One Rule for Production Systems

You won't break anything by reading. Checking logs, listing processes, looking at files —
these are all safe. The line is **writing**: modifying files, restarting services,
changing configuration. Stay read-only until you understand a system.

When in doubt, ask. Every experienced engineer on your team has made mistakes on production
systems. They'd rather answer a question than clean up an incident.

---

Ready? Start with **[Getting Access](getting_access.md)**.
