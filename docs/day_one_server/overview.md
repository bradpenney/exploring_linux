# Day One: Logging Into Your Server

!!! tip "You just got SSH credentials. Don't panic."

## Welcome to Your First Server

So you're a developer, and someone just handed you SSH credentials to a Linux server. Maybe it's your first DevOps task, maybe you're joining a team that runs their app on Linux, or maybe someone said "Hey, can you check the logs on the staging server?" and you thought *what logs? which server? how?*

**You're in the right place.**

This guide is for developers who've been given access to an enterprise Linux server and aren't quite sure where to start. We're talking production boxes, staging environments, that EC2 instance your team relies on - real servers running real applications.

## What You'll Learn

By the end of this path, you'll know how to:

- **Connect** to a Linux server via SSH (from Windows, Mac, or Linux)
- **Orient yourself** after login - where am I, what is this server, who am I?
- **Explore safely** - read logs, check processes, find files without breaking anything
- **Understand your permissions** - what you can and can't do
- **Read logs like a pro** - tail, grep, journalctl
- **Find help** - documentation, team wikis, who to ask
- **Avoid common mistakes** - the "don't do this" guide for production safety

## Who This Is For

**Perfect for:**

- Developers who've been given server access for the first time
- Junior DevOps folks starting their journey
- Anyone who's heard "just SSH into the server" and thought "...how?"
- Developers moving from Windows/Mac development to Linux servers

**Not quite right for you?**

If you don't have a Linux server to connect to yet, check out [Day One: Installing Linux Yourself](../day_one_install/overview.md) instead. That path will help you set up your own Linux environment for learning.

## The Articles

Work through these in order, or jump to what you need:

1. **[Connecting via SSH](ssh_connection.md)** - From Windows, Mac, or Linux
2. **[First 60 Seconds](orientation.md)** - Where am I? What is this?
3. **[Understanding Your Permissions](permissions.md)** - What can I actually do here?
4. **[Safe Exploration](safe_exploration.md)** - How to look around without breaking things
5. **[Reading Logs Like a Pro](reading_logs.md)** - tail, journalctl, and grep
6. **[Finding Documentation](finding_docs.md)** - Where's the team wiki?
7. **[Common First Tasks](first_tasks.md)** - Checking status, finding configs
8. **[The "Don't Do This" Guide](safety_guide.md)** - Production safety rules

## What's Next?

Once you're comfortable navigating a server and reading logs, you're ready for [Level 1: Everyday Navigation](../level_1/overview.md). That's where you'll level up your command-line skills with the tools you'll use hundreds of times a day.

## The Philosophy

Throughout this path, we emphasize **safety first**. Production servers are scary because they're running real applications serving real users. We'll teach you how to explore confidently while staying in read-only mode until you understand the system better.

Remember: **You won't break production by looking at things.** It's okay to be cautious. It's okay to ask questions. Everyone was new to this once.

Let's get started.
