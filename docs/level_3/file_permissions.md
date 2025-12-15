# File Permissions: Who Can Do What?

!!! quote "Understanding the bouncer at the door of every file"

## The "Permission denied" Mystery

You've probably seen it a dozen times already:
```
bash: /etc/hosts: Permission denied
```
Why? You're logged in. You can see the file. Why can't you edit it?

This isn't a bug; it's a core feature of Linux's security model. Every file and directory has a set of rules attached to it, like a bouncer at a club, deciding who gets in and what they're allowed to do.

This level teaches you how to read the bouncer's list (`ls -l`), how to talk to the bouncer (`chmod`), and how to change who's on the list (`chown`). Understanding this is the key to solving "Permission denied" errors and working effectively on a multi-user system.

## Decoding the Permission String

When you run `ls -l`, you see this cryptic string at the beginning of each line:
```
-rwxr-xr--
```
Let's break it down. It's composed of four parts:

`[type] [owner permissions] [group permissions] [other permissions]`

```bash
   -        rwx      r-x      r--
   ^         ^        ^        ^
File Type  Owner    Group    Other
```

1.  **File Type:** The first character.
    *   `-`: A regular file.
    *   `d`: A directory.
    *   `l`: A symbolic link (a shortcut).

2.  **Owner Permissions:** The next three characters (`rwx`). This is what the file's owner can do.

3.  **Group Permissions:** The next three (`r-x`). This is what members of the file's group can do.

4.  **Other Permissions:** The last three (`r--`). This is what *everyone else* can do.

### What `r`, `w`, and `x` Mean

**For Files:**
*   `r` (Read): You can open and view the contents of the file.
*   `w` (Write): You can modify or delete the contents of the file.
*   `x` (Execute): You can run the file as a program or script.

**For Directories:**
This is less intuitive, but very important:
*   `r` (Read): You can list the contents of the directory (i.e., run `ls`).
*   `w` (Write): You can create, delete, and rename files *within* the directory.
*   `x` (Execute): You can `cd` into the directory. You need `x` to access any files or subdirectories inside.

!!! warning "Directory Permissions"
    You can have `r` permission on a directory but not `x`. This means you can see the names of the files inside (`ls`), but you can't access them (`cat file.txt` will fail). You need both `r` and `x` to effectively work with a directory.

## Changing Permissions: `chmod`

`chmod` (change mode) is the command used to modify these permissions. There are two ways to use it: symbolic and octal.

### Symbolic Mode (Easier to Read)

Symbolic mode uses letters to represent who gets what permission.

-   **Who:** `u` (user/owner), `g` (group), `o` (other), `a` (all).
-   **Action:** `+` (add permission), `-` (remove permission), `=` (set exact permission).
-   **Permission:** `r`, `w`, `x`.

**Examples:**

```bash title="Add execute permission for the owner"
chmod u+x myscript.sh
```

```bash title="Remove write permission for the group and others"
chmod go-w sensitive-file.txt
```

```bash title="Give everyone read permission"
chmod a+r public-file.txt
```

```bash title="Set permissions exactly: owner can rwx, group can r-x, others can r--"
chmod u=rwx,g=rx,o=r myfile.sh
```

### Octal (Numeric) Mode (Faster for Experts)

Octal mode uses numbers to represent permissions. It's faster to type but requires a bit of mental math.

Each permission has a numeric value:
*   `r` = 4
*   `w` = 2
*   `x` = 1

You add them up for each category (owner, group, other).

| Permission | Octal Value |
|:---|:---|
| `---` | 0 |
| `--x` | 1 |
| `-w-` | 2 |
| `-wx` | 3 (2+1) |
| `r--` | 4 |
| `r-x` | 5 (4+1) |
| `rw-` | 6 (4+2) |
| `rwx` | 7 (4+2+1) |

You then combine the three octal digits for owner, group, and other.

**Examples:**

```bash title="Set rwxr-xr-x (755)"
chmod 755 myscript.sh
```
-   Owner: `rwx` = 4+2+1 = **7**
-   Group: `r-x` = 4+0+1 = **5**
-   Other: `r-x` = 4+0+1 = **5**

```bash title="Set rw-r--r-- (644) - common for files"
chmod 644 document.txt
```
-   Owner: `rw-` = 4+2+0 = **6**
-   Group: `r--` = 4+0+0 = **4**
-   Other: `r--` = 4+0+0 = **4**

```bash title="Set rwx------ (700) - private executable"
chmod 700 private_script.sh
```
-   Owner: `rwx` = 4+2+1 = **7**
-   Group: `---` = 0+0+0 = **0**
-   Other: `---` = 0+0+0 = **0**

### Recursive `chmod`

To apply permissions to a directory and everything inside it, use the `-R` flag.

```bash title="Make all files in a directory readable by group"
chmod -R g+r my_project/
```

!!! danger "Be Careful with `chmod -R`"
    Applying `chmod -R 777` to a directory is a common but dangerous mistake that makes everything publicly writable. Be very specific with recursive changes.

## Changing Ownership: `chown`

`chown` (change owner) changes the user and/or group that owns a file or directory.

**Basic Syntax:**
`chown [new_user]:[new_group] filename`

**Examples:**

```bash title="Change the owner to 'jane'"
sudo chown jane report.txt
```
*(You need `sudo` because you're giving a file to someone else).*

```bash title="Change the group to 'developers'"
sudo chown :developers report.txt
```

```bash title="Change both owner and group"
sudo chown jane:developers report.txt
```

### Recursive `chown`

Like `chmod`, `chown` uses `-R` to change ownership for a directory and all its contents. This is extremely common.

```bash title="Change ownership of an entire web directory"
sudo chown -R www-data:www-data /var/www/my-app
```
This is a standard command to ensure the web server user (`www-data`) can read the application files.

## Practical Examples & Scenarios

### Making a Script Executable
You just downloaded a script. You try to run it:
```bash
./install.sh
# bash: ./install.sh: Permission denied
```
Check permissions:
```bash
ls -l install.sh
# -rw-r--r-- 1 brad brad 4522 Dec 14 11:00 install.sh
```
It's missing the `x` (execute) permission. Fix it:
```bash
chmod u+x install.sh
./install.sh
```

### Securing a Private Key
Your SSH key should only be readable by you.
```bash
ls -l ~/.ssh/id_rsa
# -rw-rw-r-- 1 brad brad 1823 Dec 14 11:05 id_rsa
```
This is too permissive. SSH will complain. Lock it down:
```bash
chmod 600 ~/.ssh/id_rsa
ls -l ~/.ssh/id_rsa
# -rw------- 1 brad brad 1823 Dec 14 11:05 id_rsa
```
`600` (`rw-------`) is the correct permission for private keys.

### Sharing a File with a Group
You have a file that you and your 'dev' group colleagues need to edit.
```bash
ls -l shared_notes.txt
# -rw-r--r-- 1 brad brad 1024 Dec 14 11:10 shared_notes.txt
```
The group can only read it.
```bash
# First, ensure it belongs to the 'dev' group
sudo chown :dev shared_notes.txt

# Now, add write permission for the group
chmod g+w shared_notes.txt

ls -l shared_notes.txt
# -rw-rw-r-- 1 brad dev 1024 Dec 14 11:10 shared_notes.txt
```

## Practice Exercises

**Exercise 1: Symbolic `chmod`**
Create a file `test.txt`. Give the owner read/write, the group read-only, and others no permissions.
```bash
touch test.txt
chmod u=rw,g=r,o=--- test.txt
ls -l test.txt
# Should show: -rw-r-----
```

**Exercise 2: Octal `chmod`**
Create a script `hello.sh`. Use octal notation to give it `rwxr-x---` permissions.
```bash
touch hello.sh
chmod 750 hello.sh
ls -l hello.sh
# Should show: -rwxr-x---
```

**Exercise 3: Change Ownership**
Create a directory `project_x`. Change its owner to `root` and its group to `staff`.
```bash
mkdir project_x
sudo chown root:staff project_x
ls -ld project_x
# Should show: drwxr-xr-x ... root staff ... project_x
```

## Key Takeaways
-   **Permissions control who can read, write, and execute.**
-   They apply to three categories: **owner**, **group**, and **other**.
-   `ls -l` is how you view permissions.
-   `chmod` changes permissions (symbolic `u+x` or octal `755`).
-   `chown` changes ownership (`user:group`).
-   You need `sudo` to change ownership to someone else or to modify permissions on files you don't own.
-   For directories, `x` means you can enter it (`cd`).

Permissions are a fundamental concept that, once mastered, will make you a much more effective and confident Linux user.
