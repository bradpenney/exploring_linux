---
title: "Using Shell History"
date: 2023-03-14T20:42:56-03:00
draft: false 
---

Most [Command Line Shells]({{< ref "shells.md" >}}) have a built-in feature to record commands that have been issued.  This has two purposes - a record of what was done as well as a convenient way to repeat commands.  For the purposes of this discussion, the focus will be BASH, simply because it is the most commonly used enterprise command line shell.

To view commands that have been run, issue the `history` command.  These are stored in the `~/.bash_history` file.  

![Bash History]({{< siteurl >}}/images/bashHistory.png)

The file size is limited based by two environment variables - `HISTSIZE` and `HISTFILESIZE`.  These are declared in a couple of different places depending on this distribution in question.  In RHEL family distributions, `/etc/profile` has a default value of 1,000 for `HISTSIZE`, and in the Debian family, each user inherits a `HISTFILESIZE` of 2,000 and a `HISTSIZE` of 1,000 from the `/etc/skel/.bashrc`
