# Disk Space Management: df and du

!!! quote "Where did all my disk space go?"

## The Inevitable Problem

It's one of the most common alerts a sysadmin will ever get: `CRITICAL: Filesystem / is 95% full`.

When a disk fills up, bad things happen. Applications can't write temporary files, databases can crash, logs can't be written, and the whole system can become unstable. Knowing how to quickly find out *what* is using up all the space is a critical skill.

Two essential commands handle 99% of disk space investigation:
-   **`df`**: **D**isk **F**ilesystem - Shows an overview of all mounted filesystems and their total usage.
-   **`du`**: **D**isk **U**sage - Shows the space used by specific files and directories.

**The Analogy:** `df` is like asking "How big is my filing cabinet, and how many drawers are full?" `du` is like taking a single drawer and weighing each individual folder inside it to see which is heaviest.

## `df`: The Filesystem Overview

The `df` command is your first stop. It gives you the big picture.

The most useful combination is `df -h`.
-   `-h`: **H**uman-readable. Shows sizes in K (Kilobytes), M (Megabytes), and G (Gigabytes) instead of just bytes.

```bash
df -h
```
**Output:**
```
Filesystem      Size  Used Avail Use% Mounted on
/dev/vda1        79G   50G   25G  67% /
tmpfs           1.9G     0  1.9G   0% /dev/shm
tmpfs           783M  1.2M  782M   1% /run
tmpfs           5.0M     0  5.0M   0% /run/lock
/dev/vda15      105M  6.1M   99M   6% /boot/efi
tmpfs           392M  4.0K  392M   1% /run/user/1000
```

**How to Read This:**
-   `Filesystem`: The name of the storage device or partition.
-   `Size`: Total size of the filesystem.
-   `Used`: How much space is used.
-   `Avail`: How much space is available.
-   `Use%`: The percentage of space used. **This is the most important column.**
-   `Mounted on`: Where this filesystem is accessible in the directory tree.

**What to Look For:**
-   Find the line with a `Use%` of 85% or higher. That's your problem area.
-   The most common culprit is the root filesystem, mounted on `/`.

### Inodes vs. Space (`-i`)

Rarely, you can run out of **inodes** before you run out of space. An inode is a data structure that stores metadata about a file. If you have millions of tiny, empty files, you can exhaust all available inodes.

`df -i` shows inode usage. If `IUse%` is at 100%, you need to delete files, even if they are empty.

## `du`: The Directory Usage Detective

You've used `df -h` and found that `/` is 95% full. Now you need to find out *what* inside `/` is taking up all the space. This is the job for `du`.

Running `du` by itself is not very useful; it lists the size of every single subdirectory. You almost always want to use flags to summarize.

The most common combination is `du -sh [directory]`.
-   `-s`: **S**ummarize. Shows only the total for the specified directory, not for every subdirectory.
-   `-h`: **H**uman-readable.

```bash title="Show the total size of the /var/log directory"
sudo du -sh /var/log
```
**Output:**
```
1.2G	/var/log
```

### The "Drill-Down" Workflow

This is the core workflow for hunting down disk space issues.

1.  **Start at the root of the full filesystem.** Use `du` to check the size of each top-level directory.
    ```bash title="Find the largest directories in /"
    sudo du -sh /* 2>/dev/null
    ```
    *(The `2>/dev/null` hides "Permission denied" errors for directories you can't access).*

2.  **This produces a lot of output. Let's make it more useful.** Pipe it to `sort` and `head` to find the top offenders.
    ```bash title="Find the top 10 largest directories in /var"
    sudo du -sh /var/* 2>/dev/null | sort -hr | head -10
    ```
    - `sort -h`: Sorts human-readable numbers correctly (e.g., 2G > 100M).
    - `sort -r`: Reverses the sort, so the largest are at the top.

    **Output:**
    ```
    1.2G	/var/log
    512M	/var/lib
    10M	    /var/spool
    ...
    ```
    Aha! `/var/log` is using 1.2G.

3.  **Drill down into the culprit.** Now repeat the process on the directory you just identified.
    ```bash title="Find the top 10 largest files/dirs in /var/log"
    sudo du -sh /var/log/* 2>/dev/null | sort -hr | head -10
    ```
    **Output:**
    ```
    800M	/var/log/journal
    300M	/var/log/nginx
    50M	/var/log/syslog
    ...
    ```
    Now we see the `journal` and `nginx` log directories are the main problem.

You repeat this process, drilling down layer by layer, until you find the specific large files.

## Finding Large Files with `find`

While `du` is great for finding large *directories*, `find` is excellent for locating individual large *files*.

```bash title="Find all files in /var larger than 100MB"
sudo find /var -type f -size +100M -exec ls -lh {} \;
```
-   `-type f`: Find only files.
-   `-size +100M`: Find files larger than 100 Megabytes. (`G` for Gigabytes, `k` for Kilobytes).
-   `-exec ls -lh {} \;`: For each file found, execute `ls -lh` on it to see its details.

## Common Culprits for Full Disks

-   `/var/log`: Log files that have grown too large and haven't been rotated.
-   `/tmp`: Temporary files that weren't cleaned up by an application.
-   `/home/[user]/`: A user has downloaded large files or has a runaway application.
-   `/var/cache/apt/archives`: On Debian/Ubuntu, the cache of downloaded `.deb` packages can grow large.
-   Application-specific cache directories.

## Cleaning Up Disk Space

Once you've identified the problem, here are some safe ways to clean up.

-   **Clean apt cache (Debian/Ubuntu):**
    ```bash
    sudo apt-get clean
    sudo apt-get autoremove
    ```
-   **Prune `journald` logs:**
    ```bash
    sudo journalctl --vacuum-size=100M
    ```
    This will delete old journal files until the total size is under 100MB.

-   **Safely clear log files:** **Don't just `rm` a log file that's in use!** The service might hold it open. It's better to truncate it.
    ```bash title="Safely empty a large log file"
    sudo truncate -s 0 /var/log/some_large_log_file.log
    ```

-   **Delete old backups or temporary files:** If you find old `.tar.gz` backups or files in `/tmp`, it's usually safe to delete them with `rm`.

## Practice Exercises

**Exercise 1: Check your root filesystem**
Run `df -h`. What is the `Use%` of your main filesystem (mounted on `/`)?

**Exercise 2: Find the largest directory in your home folder**
Run `du -sh ~/* | sort -hr | head -5` to see the top 5 largest items in your home directory. Is it what you expected?

**Exercise 3: Find a large file**
Create a large dummy file, then find it.
```bash
dd if=/dev/zero of=large_file.tmp bs=1M count=200 # Creates a 200MB file
find . -type f -size +100M
rm large_file.tmp
```

## Key Takeaways
-   **`df -h`** gives a high-level overview of **filesystem** usage. Start here.
-   **`du -sh`** shows the total size of a **directory**.
-   The "drill-down" workflow is key: `du -sh /path/* | sort -hr | head -10`.
-   **`find`** is great for locating individual large files by size.
-   Common culprits are in `/var/log`, `/tmp`, and `/home`.
-   Be careful when deleting files. Use `truncate` for logs that might be in use.
