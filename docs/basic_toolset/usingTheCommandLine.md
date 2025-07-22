---
title: "Using The Command Line"
date: 2023-03-19T20:16:18-03:00
draft: false 
---

In Enterprise Linux, the command line is the most common tool-of-choice.  Being comfortable with its use is paramount; most developers and administrators will SSH into a server and use the command line for their day to day activities.

## CLI Command Syntax

Most standard commands are made up of 3 components - the second and third are sometimes optional, depending on the context:

1) Command
2) Option (optional, depending on context)
3) Argument (optional, depending on context)

For example, a standard command could be:

``` bash
ls -ltr /etc/
```

Which is broken into the 3 components like this:


``` bash
  ls    -ltr    /etc/
   ^      ^       ^
COMMAND OPTION ARGUMENT

```

## CLI Commands with Irregular Options
Not every command follows the structure above.  Many, especially more advanced commands follow different patterns:
``` bash
grep -r 'conf' /etc/ # Recursively search for the string "conf" in all files in /etc
find /etc -name "*journald**" -exec ls -ltr {} \; #  Find a file with a name that contains "journald" and give a long listing to the filename 
ps aux # List the processes running on the system (note there is no hyphen used at all)
```

## Single vs Double Hyphen Options
Note that some commands accept both single hyphen and double-hyphen commands.  Single-hyphen commands are interpreted as a different option per letter, but double-hyphen commands are interpreted as full words.  For example:

``` bash
lvcreate -h
lvcreate --help
```

Both of these commands will result in the same output.

## CLI Visual Cues

It is possible to differentiate visually whether the CLI user is `root` or a normal user.

A normal user's prompt will resemble this one (note the `$`):

``` bash
[brad@localhost ~]$ <commandGoesHere>
```

However, the `root` user will have a "hash-tag" included in the prompt:

``` bash
[root@localhost ~]# <commandGoesHere>
```
