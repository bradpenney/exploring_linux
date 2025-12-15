# Understanding Users and Groups

!!! quote "Who you are determines what you can do"

## The Multi-User World

Linux was designed from the ground up to be a multi-user system. Even if you're the only person using your computer, you're still a "user" in the eyes of the operating system. Every process that runs, every file that's created, is owned by a user.

This user and group system is the bedrock of Linux security and permissions. Understanding who you are, what groups you belong to, and what that means is essential for working on any Linux system.

## The User: Your Identity

### Who Am I Right Now? (`whoami`)

The simplest question you can ask the system is "who am I?".

```bash
whoami
```
**Output:**
```
brad
```
This command prints the username of the current user. It's simple, direct, and useful for confirming your identity, especially in scripts.

### What is a User Account?

A user account is more than just a name. It's a collection of properties that define your identity on the system:
-   **Username:** A human-readable name (e.g., `brad`).
-   **User ID (UID):** A unique number that the system uses to identify you.
-   **Primary Group ID (GID):** The ID of your default group.
-   **Home Directory:** Your personal space on the filesystem (e.g., `/home/brad`).
-   **Default Shell:** The command-line interpreter you get when you log in (e.g., `/bin/bash`).

### The Superuser: `root`

There is one special user: `root`. The `root` user has UID 0 and has unlimited power to do anything on the system. It can read any file, kill any process, and change any setting. For this reason, you should rarely log in directly as `root`. Instead, you use the `sudo` command to temporarily gain `root` privileges for specific tasks.

## The Group: Your Team

A **group** is a collection of users. Groups make it easier to manage permissions. Instead of giving five different users access to a file, you can add all five to a group and give the *group* access.

-   **Primary Group:** Every user has one primary group. When you create a new file, it's typically associated with your primary group.
-   **Supplementary Groups:** A user can be a member of many other groups, gaining their permissions as well.

## The Whole Story: `id` and `groups`

To see your full identity—user, primary group, and all supplementary groups—use the `id` command.

```bash
id
```
**Output:**
```
uid=1000(brad) gid=1000(brad) groups=1000(brad),10(wheel),998(docker)
```
**Breakdown:**
-   `uid=1000(brad)`: Your User ID is 1000, and your username is `brad`.
-   `gid=1000(brad)`: Your primary Group ID is 1000, and its name is `brad`.
-   `groups=...`: All the groups you belong to. In this case, `brad`, `wheel` (which often grants `sudo` access), and `docker` (which allows running docker commands).

If you just want to see the names of the groups you're in, the `groups` command is a simpler alternative.

```bash
groups
# brad wheel docker
```

## Where User and Group Information is Stored

This information isn't magic; it's stored in plain text files in `/etc`.

-   `/etc/passwd`: Lists all user accounts on the system.
-   `/etc/group`: Lists all groups on the system.

You can inspect these files to see all users and groups.

```bash title="Look at the user database"
cat /etc/passwd | head -5
```
**Output:**
```
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin
sys:x:3:3:sys:/dev:/usr/sbin/nologin
sync:x:4:65534:sync:/bin:/bin/sync
```
The fields are separated by colons: `username:password_placeholder:UID:GID:description:home_directory:shell`.

```bash title="Look at the group database"
cat /etc/group | grep "docker"
```
**Output:**
```
docker:x:998:brad,jane
```
This shows the group `docker` has GID 998 and its members are `brad` and `jane`.

## Managing Users and Groups (Admin Commands)

Managing users and groups is a system administration task and usually requires `sudo`. You won't use these every day, but it's good to know they exist.

-   **Users:** `useradd`, `usermod`, `userdel`
-   **Groups:** `groupadd`, `groupmod`, `groupdel`
-   **Adding a user to a group:** `gpasswd -a [username] [groupname]` or `usermod -aG [groupname] [username]`

## Privileges and `sudo`

As mentioned, you shouldn't work as `root`. Instead, you use `sudo` (superuser do) to run a single command with root privileges.

To be able to use `sudo`, your user account must typically be in a special group—usually named `wheel` or `sudo`.

You can check what `sudo` privileges you have with `sudo -l`.

```bash
sudo -l
```
**Output (Full Access):**
```
User brad may run the following commands on this host:
    (ALL : ALL) ALL
```
This means user `brad` can run any command as any user.

**Output (Limited Access):**
```
User jane may run the following commands on this host:
    (root) /bin/systemctl restart nginx
```
This means user `jane` can *only* restart the nginx service with `sudo`.

## Why It All Matters: Connecting to File Permissions

The user and group concepts are directly tied to file permissions. When you run `ls -l`, you see owner and group columns:

```
-rw-rw-r-- 1 brad developers 4096 Dec 14 12:00 report.txt
             ^    ^
           Owner  Group
```

-   The **owner** permissions (`rw-`) apply to the user `brad`.
-   The **group** permissions (`rw-`) apply to anyone in the `developers` group.
-   The **other** permissions (`r--`) apply to everyone else.

Understanding who you are (`id`) is the key to understanding why you can or cannot access a file.

## Practice Exercises

**Exercise 1: Check your identity**
Run `whoami`, `id`, and `groups` to see your own user and group information.

**Exercise 2: Find a system user**
Look for the `www-data` or `nginx` user in `/etc/passwd`. What is their default shell?
```bash
grep "nginx" /etc/passwd
```
*(You'll likely see `/usr/sbin/nologin`, meaning they can't log in interactively).*

**Exercise 3: Check your sudo power**
Run `sudo -l` to see what commands you are allowed to run with `sudo`.

## Key Takeaways
-   Every process and file in Linux is owned by a **user** and a **group**.
-   `whoami` tells you your username.
-   `id` gives you your full identity: UID, GID, and supplementary groups.
-   The `root` user (UID 0) is the all-powerful superuser.
-   The `/etc/passwd` and `/etc/group` files store user and group information.
-   Your group memberships determine your access rights to files and directories.
-   `sudo` is used to run commands with elevated (usually `root`) privileges.
