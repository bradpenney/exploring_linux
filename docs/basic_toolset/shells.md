# Enterprise Command Line Shells

In UNIX and Linux, a shell is the basic program you use at the command
line. Some folks say the name is a metaphor for a snail — the shell wraps
around the kernel. Like most things in Linux, there are lots of different
shells, often building on each other and fixing the quirks of earlier
versions. Examples include [ZSH](https://ohmyz.sh/),
[FISH](https://fishshell.com/), and plenty more.

??? tip "Graphical vs Command-Line Shells"

    Technically, shells can be graphical too — `GNOME` and `KDE`
    are popular examples. These are rarely (if ever) used on servers.

In Enterprise Linux, only a few command-line shells are widely used:

## BASH (Bourne-Again Shell)

- By far the most common shell in Enterprise Linux. Like a good cup of coffee, ☕ it's always there when you need it. All Linux distributions have BASH available, even if it's not the default. Not all UNIX systems include BASH.
- Standard file location: `/bin/bash` or `/usr/bin/bash`
- `#!/bin/bash` is usually at the top of shell scripts so the kernel
  knows which interpreter to use.

## KSH (Korn Shell)

- Still popular on some UNIX systems like AIX.
- Lacks some features standard in BASH, like tab-completion and
  "up-arrow" history.

## SH (Shell)**

- The original shell interface used in UNIX.
- Still exists in modern Linux distributions.
- Standard file location: `/bin/sh` or `/usr/bin/sh`
