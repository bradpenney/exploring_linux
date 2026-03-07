# File Permissions
File permissions in Linux can feel like a maze at first — lots of letters,
dashes, and gotchas. But don't worry: once you break it down, it's actually
pretty logical. 🔐

One big thing to keep in mind: in Linux, everything is a file. Yep, everything
— text files, devices, directories, even your monitor connection. And all of
them have permissions attached.

You can peek at permissions with ls -ltr. For example:

```shell {title="Listing Files with Permissions"}
-rwxr--r--  1 root root     2354 Feb 17 08:54 .bashrc

```

## File Ownership
Every file has two owners:

- a user (the actual owner)
- a group (a collection of users)

Here’s that same example with some arrows added:

``` shell {title="Group and User Ownership"}
-rwxr--r--  1 root   root     2354 Feb 17 08:54 .bashrc
               ^      ^
             owner  group
```

??? tip "Permissions are not additive"

    Linux permissions are not additive.  This means that if a user falls into
    a category (owner, group, or other), Linux doesn't perform any further
    checks or processing.  Whatever the permissions of the first matching
    category are the effective permissions for the file.

## Permissions on Files
Now let’s zoom in on that left-hand side:

``` bash
   -        rwx    r--    r--
   ^         ^      ^      ^
file type  owner  group  other
```

That cryptic string breaks down into three sets of permissions:
- r = read (open the file and look at it)
- w = write (change it)
- x = execute (run it as a program/script)

In the `.bashrc` example:

- The owner (root) can read, write, and execute.
- The group (root) can only read.
- Everyone else (the “other” category) can only read too.
