# Permission Troubleshooting: Solving "Permission Denied"

!!! quote "It's not an error, it's a puzzle."

## The Inevitable Error

You're going to see this message a lot.
```
Permission denied
```
It's not a sign that you've done something wrong. It's Linux working as designed, protecting files and keeping the system stable. Think of it less as an error and more as a puzzle. Your job is to figure out *why* the bouncer at the door said "no."

This guide provides a systematic, step-by-step methodology for solving any permission puzzle.

## The Troubleshooting Flowchart

When you get a "Permission denied" error, don't just immediately try `sudo`. Instead, walk through these questions to understand the *why*.

1.  **What am I trying to do?** (Read, Write, or Execute?)
2.  **Who am I?** (Run `id` to check your user and groups).
3.  **What are the permissions on the target?** (Run `ls -l` for a file or `ls -ld` for a directory).
4.  **Do they match?** (Does my user or one of my groups have the required permission?)
5.  **How do I fix it?** (Use `chmod`, `chown`, or `sudo` if appropriate).

Let's apply this flowchart to common scenarios.

---

### Scenario 1: Cannot Read a File

You're trying to view a log file.

**The command:**
```bash
cat /var/log/nginx/error.log
```
**The error:**
```
cat: /var/log/nginx/error.log: Permission denied
```

**Let's troubleshoot:**

1.  **What am I trying to do?** Read a file. I need `r` permission.
2.  **Who am I?**
    ```bash
    id
    # uid=1000(brad) gid=1000(brad) groups=1000(brad),10(wheel),998(docker)
    ```
    I am user `brad`, and I am in the groups `brad`, `wheel`, and `docker`.
3.  **What are the permissions on the target?**
    ```bash
    ls -l /var/log/nginx/error.log
    # -rw-r----- 1 www-data adm 12345 Dec 14 13:00 /var/log/nginx/error.log
    ```
    -   The owner, `www-data`, can read and write (`rw-`).
    -   The group, `adm`, can only read (`r--`).
    -   "Other" users have no permissions (`---`).
4.  **Do they match?**
    -   I am not the user `www-data`.
    -   I am not in the group `adm`.
    -   Therefore, I fall into the "other" category, which has no permissions. The "Permission denied" error is correct.

**Solutions:**

-   **The `sudo` way (if you have permission):** Run the command with `sudo` to temporarily become `root`. `root` bypasses standard permission checks.
    ```bash
    sudo cat /var/log/nginx/error.log
    ```
-   **The "right" way (long-term):** If you need to read these logs often, you should be in the `adm` group.
    ```bash
    # Ask an administrator to run this:
    sudo usermod -aG adm brad
    ```
    After you log out and log back in, your `id` will show the `adm` group, and the original `cat` command will work without `sudo`.

---

### Scenario 2: Cannot Execute a Script

You have a script you want to run.

**The command:**
```bash
./myscript.sh
```
**The error:**
```
bash: ./myscript.sh: Permission denied
```

**Let's troubleshoot:**

1.  **What am I trying to do?** Execute a file. I need `x` permission.
2.  **Who am I?**
    ```bash
    id
    # uid=1000(brad) ...
    ```
    I am user `brad`.
3.  **What are the permissions on the target?**
    ```bash
    ls -l myscript.sh
    # -rw-r--r-- 1 brad brad 256 Dec 14 13:15 myscript.sh
    ```
    -   The owner is `brad` (that's me!).
    -   The owner permissions are `rw-`.
4.  **Do they match?** I am the owner, but my permissions are `rw-`. The `x` (execute) bit is missing. The denial is correct.

**Solution:**

-   **The `chmod` way:** Add the execute permission for the user (owner).
    ```bash
    chmod u+x myscript.sh
    ```
    Now check the permissions again:
    ```bash
    ls -l myscript.sh
    # -rwxr--r-- 1 brad brad 256 Dec 14 13:15 myscript.sh
    ```
    The `x` is there. Now `./myscript.sh` will work.

---

### Scenario 3: Cannot `cd` into a Directory

You're trying to change into a directory owned by another user.

**The command:**
```bash
cd /var/www/html
```
**The error:**
```
bash: cd: /var/www/html: Permission denied
```

**Let's troubleshoot:**

1.  **What am I trying to do?** Enter a directory. I need `x` (execute) permission on that directory.
2.  **Who am I?** User `brad`.
3.  **What are the permissions on the target?** Use `ls -ld` to see permissions for the directory itself, not its contents.
    ```bash
    ls -ld /var/www/html
    # drwxr-x--- 2 www-data www-data 4096 Dec 14 13:20 /var/www/html
    ```
    -   Owner `www-data` can `rwx`.
    -   Group `www-data` can `r-x`.
    -   Other has `---`.
4.  **Do they match?** I am not `www-data` and I'm not in the `www-data` group. I am "other," so I have no permissions. The denial is correct.

**Solutions:**

-   Use `sudo` to switch to a user who *does* have permission: `sudo -u www-data -s`
-   If you need to be able to browse this directory, ask to be added to the `www-data` group.

---

### The "Check the Whole Path" Rule

This is a common "gotcha". To access a file or directory, you need **execute (`x`) permission on *every parent directory* in its path.**

Consider this structure:
```
/
└── home/ (drwxr-xr-x)
    └── brad/ (drwx--x--x)  <-- Missing 'x' for group/other
        └── report.txt (-rw-rw-rw-)
```
Even though `report.txt` is world-readable/writable, a user named `jane` cannot access it.

```bash
cat /home/brad/report.txt
# cat: /home/brad/report.txt: Permission denied
```
Why? Because `jane` doesn't have `x` permission on the `/home/brad` directory, so she can't "pass through" it to get to `report.txt`.

**The fix:**
```bash
chmod g+x,o+x /home/brad
```
This grants others the ability to enter the directory, where the permissions on `report.txt` itself will then apply.

## Practice Exercises

**Exercise 1: Diagnose the Read Error**
-   **Your user:** `id` shows `uid=1001(jane) groups=1001(jane)`
-   **File permissions:** `ls -l /data/report.csv` shows `-rw-r----- 1 brad staff 1024 ...`
-   **The error:** `cat /data/report.csv` gives `Permission denied`.
-   **Why?** You are `jane`, not `brad`. You are not in the `staff` group. You fall into "other," which has `---` permissions.

**Exercise 2: Diagnose the Execute Error**
-   **Your user:** `id` shows `uid=1000(brad) groups=1000(brad),100(devs)`
-   **File permissions:** `ls -l deploy.sh` shows `-rwxr-x--- 1 root devs 512 ...`
-   **The error:** `./deploy.sh` gives `Permission denied`.
-   **Why?** The file is owned by `root`. You are `brad`, but you are in the `devs` group. The `devs` group has `r-x` permissions, so you *should* be able to execute it. **Aha!** The error is not from the file permissions, but from the *shebang* line or something inside the script that `brad` does not have permission to run. Or maybe the filesystem is mounted with `noexec`. This is a more advanced problem! (But starting with `ls -l` is always the first step).

## Key Takeaways
-   "Permission Denied" is a puzzle, not a dead end.
-   Follow the methodical flow: **Who am I? What are the permissions? Do they match?**
-   You need **`r`** to read a file.
-   You need **`w`** to write to a file.
-   You need **`x`** to execute a script.
-   You need **`x`** on a directory to `cd` into it.
-   You need **`x`** on *all parent directories* in a path to access the target.
-   Use `ls -l` for files and `ls -ld` for directories to check permissions.
