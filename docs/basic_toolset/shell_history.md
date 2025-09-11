# Using Shell History

Most [Command Line Shells](shells.md) have a built-in feature to record
commands you've run. This is handy for two reasons: it keeps a record of
what you've done, and it makes it super easy to repeat commands without
retyping them. We'll focus on BASH here, since it's the most common shell
in enterprise Linux.

To see your command history, just type:

```bash
history
```

These commands are stored in your `~/.bash_history` file.

![Bash History](images/bash_history.png)

The size of your history is controlled by two environment variables:
`HISTSIZE` and `HISTFILESIZE`. Where these are set depends on your Linux
distribution. On RHEL-family systems, `/etc/profile` sets a default
`HISTSIZE` of 1,000. On Debian-based systems, each user inherits a
`HISTFILESIZE` of 2,000 and a `HISTSIZE` of 1,000 from
`/etc/skel/.bashrc`.

If you want to keep more (or fewer) commands in your history, you can
change these values in your own `~/.bashrc` file.
