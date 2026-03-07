# Using The Command Line

In Enterprise Linux, the command line is the tool of choice for most
tasks. Getting comfortable with it is key — most developers and admins
SSH into servers and use the command line for their daily work. ⌨️

## CLI Command Syntax

Most standard commands have three parts (though the last two are often
optional):

1. Command
2. Option (optional)
3. Argument (optional)

For example:

```bash
ls -ltr /etc/
```

Which breaks down like this:

```bash
  ls    -ltr    /etc/
   ^      ^       ^
COMMAND OPTION ARGUMENT
```

## CLI Commands with Irregular Options

Not every command follows this neat structure. Many advanced commands
mix things up a bit:

```bash
grep -r 'conf' /etc/ # Recursively search for "conf" in all files in /etc
find /etc -name "*journald**" -exec ls -ltr {} \; # Find files with "journald" in the name and list them
ps aux # List running processes (no hyphen for options here)
```

## Single vs Double Hyphen Options

Some commands accept both single and double hyphens. Single hyphens
usually mean each letter is a separate option, while double hyphens
spell out full words. For example:

```bash
lvcreate -h
lvcreate --help
```

Both commands will show the help output.

## CLI Visual Cues

You can tell if you're running as `root` or a normal user by looking at
the prompt.

A normal user's prompt looks like this (note the `$`):

```bash
[brad@localhost ~]$ <commandGoesHere>
```

The `root` user gets a hash (`#`) at the end:

```bash
[root@localhost ~]# <commandGoesHere>
```
