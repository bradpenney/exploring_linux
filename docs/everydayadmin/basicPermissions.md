---
title: "Basic Linux Permissions"
date: 2023-03-14T20:42:39-03:00
draft: false
---

Linux permissions are a very extensive topic that includes many pitfalls that new users often struggle with.  It is critical to realize that everything (literally everything) is a file in Linux - and will have permissions associated with it.

Permissions can be seen using the `ls -ltr` command.  For example:

``` bash 
-rwxr--r--  1 root root     2354 Feb 17 08:54 .bashrc

```

## Files Ownership
Looking at the listing above, the first thing to understand is that each file has an owner and a group.  This is clearly shown (in expanded form) below:

``` bash 
-rwxr--r--  1 root   root     2354 Feb 17 08:54 .bashrc
               ^      ^
             owner  group
```

> Linux permissions are not additive.  This means that if a user falls into a category (owner, group, or other), Linux doesn't perform any further checks or processing.  Whatever the permissions of the first matching category are the effective permissions for the file.

## Permissions on Files
The permissions are on the left side (`-rw-r--r--`) and come in three sets. These can be interpreted (in expanded form) as:

``` bash
   -        rwx    r--    r--
   ^         ^      ^      ^
file type  owner  group  other
```

So in the above scenario, `r` represents "read", `w` represents write, and `x` represents "execute".  So the `root` owner can read, write, and execute the file in question.  The `root` group can read and write, and others can read (only).
