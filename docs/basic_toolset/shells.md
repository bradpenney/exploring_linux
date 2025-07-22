---
title: "Enterprise Command Line Shells"
date: 2023-03-11T07:11:36-04:00
draft: false 
---

In UNIX and Linux, a shell is the basic program that is used in the command line.  Some believe the name is a metaphor for a snail - the shell wraps around the kernel.  Like most things in the Linux world, there are many different variations and versions, often building off each other and fixing some weakness of a previous shell.  Examples include [ZSH](https://ohmyz.sh/), [FISH](https://fishshell.com/), and many others.  

> ** Note: Technically, shells can exist in graphical form too - `GNOME` and `KDE` being popular examples.  These are rarely (if ever) used on servers.

In Enterprise Linux, only a few command-line shells are in widespread use:

1. **BASH (Borne-Again Shell)**
   - This is far-and-away the most commonly used shell in Enterprise Linux.  All Linux distributions have BASH available, even if it is not the default.  Not all UNIX distributions include BASH.
   - Standard file location: `/bin/bash` or (`/usr/bin/bash`)
   - `#!/bin/bash` is usually included at the beginning of each shell script so the kernel knows which interpreter to use

2. **KSH (Korn Shell)**
   - Popular among the remaining UNIX distributions such as AIX. 
   - Lacks many features that are standard in BASH, most notably tab-completion and "up-arrow" history
   
3. **SH (Shell)**
   - The original shell interface that was used in UNIX
   - Still exists in modern Linux distrubutions
   - Standard file location: `/bin/sh` (or `/usr/bin/sh`)
