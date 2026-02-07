# Day One: Getting Started with Linux

!!! tip "Every Linux expert started exactly where you are. This is Day One."

## Welcome to Linux

This is your first time working with a Linux system, and you're probably feeling one of two ways:

- **Excited:** "I've heard Linux runs everything! Time to learn!"
- **Nervous:** "I just got server access for work and have no idea what I'm doing..."

**Both are valid. You're in the right place.**

This guide is for anyone starting their Linux journey—whether someone handed you SSH credentials to a production server, or you're setting up your own Linux environment to learn and experiment.

## What You'll Learn

By the end of Day One, you'll have these essential Linux skills:

| Skill | What You'll Master |
|-------|-------------------|
| **Getting Access** | Connect via SSH or set up your own Linux environment |
| **Orientation** | Know where you are, what server, who you are |
| **Permissions** | Understand your access level and use sudo safely |
| **Safe Exploration** | Look around without breaking things |
| **Reading Logs** | Use tail, grep, and journalctl effectively |
| **Finding Help** | Know where to look when stuck |
| **Avoiding Mistakes** | Common pitfalls that impact production |

## Two Paths, One Destination

This guide acknowledges that people come to Linux from different starting points:

=== ":material-server-network: SSH Access"

    **You have server credentials.**

    Someone gave you an IP address, username, and password. Maybe it's a production server, staging environment, or cloud instance. You need to connect and start working—safely.

    **We'll cover:** Connecting via SSH, orienting yourself on an unfamiliar system, understanding what you can and cannot do, and staying in read-only mode until you're comfortable.

=== ":material-laptop: Local Setup"

    **You're setting up your own environment.**

    You want to learn Linux but don't have a server. You're choosing between WSL2, VirtualBox, cloud providers, or a physical install. You want a safe playground to experiment.

    **We'll cover:** Quick setup options with links to official guides, choosing what works for your situation, and validating your environment is ready.

**Either way:** Once you've got access to a Linux terminal, you're on the same journey. The commands work the same, the concepts are identical, and you'll build the same foundational skills.

## Who This Is For

<div class="grid cards" markdown>

-   :material-account-check: **Perfect For**

    ---

    **Developers** — First-time server access

    **Junior DevOps** — Starting your journey

    **Students** — Learning for class or career

    **Hobbyists** — Hands-on exploration

    **Career Changers** — Moving to systems work

-   :material-shield-check: **You Don't Need**

    ---

    **Prior Experience** — We assume none

    **CS Degree** — Concepts explained clearly

    **Command Memorization** — We teach how to find help

    **Fear** — Safety emphasized throughout

</div>

## The Articles

Work through these in order for the full Day One experience:

1. **[Getting Access to Linux](getting_access.md)** - Connect via SSH or set up your own environment
2. **[First 60 Seconds: Orientation](orientation.md)** - Where am I? What is this server? Who am I?
3. **[Understanding Your Permissions](permissions.md)** - What can I actually do here? Groups, sudo, and access levels
4. **Safe Exploration** - How to look around without breaking things (coming soon)
5. **Reading Logs Like a Pro** - tail, journalctl, and grep (coming soon)
6. **Finding Documentation** - Where's the team wiki? (coming soon)
7. **Common First Tasks** - Checking status, finding configs (coming soon)
8. **The "Don't Do This" Guide** - Safety rules for real systems (coming soon)

!!! note "Articles Publishing Soon"
    Articles are being published as they're reviewed for quality. Start with Getting Access to get connected to a Linux system.

## The Philosophy

Throughout Day One, we emphasize **safety and confidence**. How you approach Linux depends on your environment:

=== ":material-server: Production Systems"

    **If you're working on a real server** (production, staging, team infrastructure):

    - **You won't break production by looking at things.** Reading logs, checking processes, exploring files—these are safe operations.
    - **We stay read-only until you know more.** No deleting files, no restarting services, no making changes until you understand the system.
    - **It's okay to ask questions.** Everyone was new to this once. Your team would rather you ask than guess wrong.

=== ":material-laptop: Personal Systems"

    **If you're learning on your own** (VM, WSL2, personal server):

    - **Breaking things is how you learn.** In a safe environment, mistakes are educational.
    - **You can always rebuild.** VMs can be snapshotted and restored. WSL2 can be reset. Cloud instances can be deleted and recreated.
    - **Experimentation is encouraged.** Try commands. See what happens. Learn by doing.

## Our Teaching Approach

Day One focuses on **practical, immediate needs**—the skills you need in your first hours and days working with Linux.

<div class="grid cards" markdown>

-   :material-lightbulb-on: **We Teach**

    ---

    **The "Why"** — Understanding purpose, not just syntax

    **Real Scenarios** — Situations you'll actually encounter

    **Finding Answers** — How to help yourself when stuck

    **Safety Habits** — Practices that serve you forever

</div>

## What's Next?

Once you're comfortable navigating a Linux system and reading logs, you're ready for **Level 1: Everyday Navigation**. That's where you'll level up your command-line skills with the tools you'll use hundreds of times a day.

---

## Ready?

Start with **[Getting Access to Linux](getting_access.md)** and we'll get you connected to a Linux system.

Remember: The person who looks like a Linux wizard today? They had a Day One too. This is yours.
