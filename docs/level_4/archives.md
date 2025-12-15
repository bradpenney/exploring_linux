# Working with Archives: tar, gzip, and zip

!!! quote "Bundling and shrinking files for storage and transfer"

## Archiving vs. Compression

When working with files in Linux, you'll frequently need to perform two related but distinct actions:
-   **Archiving:** Combining multiple files and directories into a single file for easy transport.
-   **Compression:** Shrinking the size of a file to save space or reduce transfer time.

In the Linux world, these two actions are often performed together, but by different tools working in concert.
-   **`tar`** is the classic **archiving** tool.
-   **`gzip`** and `bzip2` are the classic **compression** tools.

The `zip` command, more common in the Windows world, does both archiving and compression in one step.

## `tar`: The Tape Archive Utility

`tar`'s name comes from "tape archive," as it was originally designed to write data to sequential tape drives for backups. Its job is to bundle many files into one.

The `tar` command's options can seem cryptic, but you'll memorize the common combinations quickly.

-   `-c`: **C**reate an archive.
-   `-x`: **E**xtract an archive.
-   `-t`: **T**est or list the contents of an archive.
-   `-v`: **V**erbose. Show the files as they are being processed.
-   `-f`: **F**ile. Specifies the archive filename. This flag should almost always be the last one.

### Creating an Archive (`-cvf`)

```bash title="Create an archive of the 'my_project' directory"
tar -cvf my_project.tar my_project/
```
This bundles everything in `my_project/` into a single file called `my_project.tar`.

### Extracting an Archive (`-xvf`)

```bash title="Extract the contents of an archive"
tar -xvf my_project.tar
```
This unpacks the contents of `my_project.tar` into the current directory.

### Listing Contents (`-tvf`)

To see what's inside an archive without extracting it:

```bash title="List the contents of an archive"
tar -tvf my_project.tar
```

## Compression: `gzip` and `bzip2`

`gzip` is the standard, fast compression tool on Linux. It compresses a single file.

```bash
# Before
# -rw-r--r-- 1 brad brad 10M large_file.log

gzip large_file.log

# After
# -rw-r--r-- 1 brad brad 1.2M large_file.log.gz
```
Notice that `gzip` removes the original file by default. To decompress it, use `gunzip`.

```bash
gunzip large_file.log.gz
```
`bzip2` is another compressor that offers higher compression ratios but is slower. It creates `.bz2` files and is decompressed with `bunzip2`.

## `tar` + `gzip`: The Perfect Combination

The most common way to archive and compress on Linux is to use `tar` and `gzip` together. This creates the familiar `.tar.gz` (or `.tgz`) file.

`tar` has built-in flags to handle compression automatically.

-   `-z`: Use **g**-**z**-ip.
-   `-j`: Use **b**-**j**-zip2.

### Creating a Compressed Archive (`-czvf`)

Think "**C**reate **Z**ipped **V**erbose **F**ile".

```bash title="Create a gzipped tar archive"
tar -czvf my_project.tar.gz my_project/
```
This creates the `my_project/` archive and then immediately compresses it with `gzip`.

### Extracting a Compressed Archive (`-xzvf`)

Think "**E**-**x**-tract **Z**ipped **V**erbose **F**ile".

```bash title="Extract a gzipped tar archive"
tar -xzvf my_project.tar.gz
```
This decompresses the archive and then extracts its contents.

## `zip`: The All-in-One Tool

The `zip` format is ubiquitous, especially when sharing files with Windows or macOS users. The `zip` command handles both archiving and compression.

### Creating a `zip` Archive

```bash title="Create a zip archive of a directory"
zip -r my_project.zip my_project/
```
The `-r` flag is crucial for recursively including all files and subdirectories.

### Extracting a `zip` Archive

The command is `unzip`.

```bash title="Extract a zip archive"
unzip my_project.zip
```

### Listing `zip` Contents

```bash title="List the contents of a zip archive"
unzip -l my_project.zip
```

## When to Use Which?

| Format | Use When... | Why? |
|:---|:---|:---|
| **`.tar.gz`** | Working on Linux, backups, distributing source code. | **The Linux standard.** Preserves file permissions, ownership, and links perfectly. |
| **`.zip`** | Sharing files with Windows/macOS users, or for simple multi-file archives. | **Cross-platform.** Everyone can open a `.zip` file easily. |

## Practical Scenarios

**"I need to back up my entire home directory."**
```bash
sudo tar -czvpf /backups/home_backup_$(date +%F).tar.gz /home
```
-   `-p`: **P**reserve permissions. Crucial for backups!

**"I need to send our web team the log files from last night."**
```bash
# Create an archive of all log files in a directory
tar -czvf nginx_logs.tar.gz /var/log/nginx/
# Now you can send the single 'nginx_logs.tar.gz' file.
```

**"A developer sent me a `project.zip` file."**
```bash
# Create a new directory and extract into it
mkdir project
cd project
unzip ../project.zip
```

## Practice Exercises

**Exercise 1: Create a tarball**
1.  Create a directory `practice` with a few empty files inside (`touch practice/file1 practice/file2`).
2.  Use `tar` to create an archive named `practice.tar` of the `practice` directory.
3.  Use `ls` to verify that `practice.tar` exists.

**Exercise 2: Create a compressed tarball**
1.  Using the same `practice` directory, create a compressed archive named `practice.tar.gz`.
2.  Use `ls -lh` to compare the size of `practice.tar` and `practice.tar.gz`.

**Exercise 3: List and Extract**
1.  Remove the original `practice` directory (`rm -r practice`).
2.  List the contents of `practice.tar.gz` without extracting it using `tar -tvf`.
3.  Extract the contents of `practice.tar.gz`.
4.  Use `ls practice` to verify the files are back.

## Key Takeaways
-   **Archiving** (`tar`) combines files; **Compression** (`gzip`) shrinks them.
-   `.tar.gz` is the standard Linux archive format.
-   `tar -czvf archive.tar.gz directory/`: **C**reate a g**Z**ipped archive.
-   `tar -xzvf archive.tar.gz`: **E**-**X**-tract a g**Z**ipped archive.
-   `zip` is a good cross-platform alternative.
-   `zip -r archive.zip directory/` and `unzip archive.zip`.
-   Use the `-p` flag with `tar` to preserve permissions during backups.
