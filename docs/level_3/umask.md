# umask: Setting Default Permissions

!!! quote "The unsung hero of Linux file security"

## The Default Permission Question

Have you ever noticed that when you create a new file, it gets specific permissions automatically?
```bash
touch newfile.txt
ls -l newfile.txt
# -rw-r--r-- 1 brad brad 0 Dec 14 14:00 newfile.txt
```
It's `644` (`rw-r--r--`).

And when you create a directory?
```bash
mkdir newdir
ls -ld newdir
# drwxr-xr-x 2 brad brad 4096 Dec 14 14:01 newdir/
```
It's `755` (`rwxr-xr-x`).

Where do these default permissions come from? The answer is the **`umask`**.

`umask` (user file-creation mode mask) is a simple but powerful setting that dictates the default permissions for all new files and directories you create. Understanding it is key to ensuring your files are as open or as private as you intend them to be from the moment they're created.

## Understanding the Mask

The `umask` works like a stencil or a "mask." It *removes* permissions from a base value. It's a "do not grant" list.

The system starts with a maximum possible permission value, and your `umask` subtracts from it.

-   **Base value for directories:** `777` (`rwxrwxrwx`). Directories can be executable.
-   **Base value for files:** `666` (`rw-rw-rw-`). For security, files are not made executable by default.

### How to Read the `umask`

To see your current `umask`, just type the command:
```bash
umask
```
**Output:**
```
0022
```
This is an octal representation. For basic permissions, you can ignore the first digit (which relates to special permissions like the sticky bit) and focus on the last three: `022`.

Let's translate `022` back to symbolic permissions:
-   `0`: No permissions are masked for the **owner**.
-   `2`: The `w` (write) permission is masked for the **group**.
-   `2`: The `w` (write) permission is masked for **others**.

So, a `umask` of `022` means "when creating a new file, remove the `w` permission for the group and for others."

## Calculating Default Permissions

The formula is simple, but requires a bit of mental gymnastics because it's based on subtraction and logic, not just numbers.

**Default Permissions = Base Value - `umask`**

Let's use the common `umask` of `022`.

### For a New Directory

1.  **Base Permission:** `777` (`rwxrwxrwx`)
2.  **`umask`:** `022` (`--- -w- -w-`)
3.  **Result:** `777 - 022 = 755` (`rwxr-xr-x`)

| | Owner (u) | Group (g) | Other (o) |
|:---|:---|:---|:---|
| **Base (777)** | `rwx` | `rwx` | `rwx` |
| **Mask (022)** | `---` | `-w-` | `-w-` |
| **Result (755)**| `rwx` | `r-x` | `r-x` |

### For a New File

1.  **Base Permission:** `666` (`rw-rw-rw-`)
2.  **`umask`:** `022` (`--- -w- -w-`)
3.  **Result:** `666 - 022 = 644` (`rw-r--r--`)

| | Owner (u) | Group (g) | Other (o) |
|:---|:---|:---|:---|
| **Base (666)** | `rw-` | `rw-` | `rw-` |
| **Mask (022)** | `---` | `-w-` | `-w-` |
| **Result (644)**| `rw-` | `r--` | `r--` |

## Changing Your `umask`

You can change your `umask` for your current terminal session.

```bash title="Set a more restrictive umask"
umask 077
```
Now let's see what happens:
```bash
touch privatefile.txt
ls -l privatefile.txt
# -rw------- 1 brad brad 0 Dec 14 14:15 privatefile.txt
```
The permissions are `600` (`666 - 066`... wait, `077`? It's bitwise, but thinking of it as subtraction from each digit works for most cases). This is perfect for private files.

To make this change permanent, add `umask 077` to the end of your `~/.bashrc` or `~/.profile` file.

## Common `umask` Values

| `umask` | Default File Perms | Default Dir Perms | Use Case |
|:---|:---|:---|:---|
| `0022` | `644` (`rw-r--r--`) | `755` (`rwxr-xr-x`) | **Most common default.** Good for general use. Others can read your files. |
| `0002` | `664` (`rw-rw-r--`) | `775` (`rwxrwxr-x`) | **Good for collaboration.** Your primary group can write to your new files. |
| `0077` | `600` (`rw-------`) | `700` (`rwx------`) | **Very private.** Only you can do anything with your new files. Recommended for `root` and on high-security multi-user systems. |

## Why `umask` Matters

-   **Security:** `umask` is your primary defense against accidentally creating files that are world-writable or world-readable. A sane `umask` (`022` or `077`) prevents you from inadvertently exposing sensitive data.
-   **Collaboration:** In a shared environment, a team might agree to set their `umask` to `002` so that any new files they create are automatically editable by other team members in the same group.

## Practice Exercises

**Exercise 1: Check your `umask`**
Run `umask`. What is your default? Based on that, what permissions should a new file and a new directory have? Verify your answer with `touch` and `mkdir`.

**Exercise 2: The Collaborative `umask`**
1.  Run `umask 002`.
2.  Create a new file: `touch collaborative_file`.
3.  Check its permissions with `ls -l collaborative_file`.
4.  What permissions did it get? Does it match your calculation (`666` - `002` = `664`)?
5.  Reset your `umask` by closing the terminal or running `umask 022`.

**Exercise 3: The Private `umask`**
What `umask` would you set to ensure that new files you create have `rw-r-----` (`640`) permissions?
??? tip "Answer"
    The base is `666`. You want `640`. The difference is `026`. So you would set `umask 026`.

## Key Takeaways
-   `umask` sets the **default permissions** for new files and directories.
-   It works by **removing** permissions from a base value.
-   Base for files is `666` (`rw-rw-rw-`).
-   Base for directories is `777` (`rwxrwxrwx`).
-   A common `umask` is `022`, which results in `644` for files and `755` for directories.
-   You can change your `umask` for the current session (`umask 077`) or permanently in `~/.bashrc`.

Understanding `umask` is a step towards mastering the Linux permission model. It allows you to define a secure and predictable environment for your work.
