# Pipes and Chaining: Combining Commands Like a Wizard

!!! quote "The magic of Linux is in combining simple tools"

## The Power of the Pipeline

You've learned powerful individual commands: `ls`, `cd`, `grep`, `sort`, `uniq`, `cut`, `awk`, `sed`. Each one is a specialized tool. But the real magic of the Linux command line isn't in any single command; it's in how you connect them.

Imagine an assembly line: raw data enters one end, gets processed by a series of specialized machines, and emerges as a polished, desired output at the other. That's a **pipeline**.

The **pipe symbol (`|`)** is the conveyor belt. It takes the output of one command and feeds it directly as input to the next.

This is how you turn simple tools into incredibly powerful data-processing machines.

## Basic Piping: `command1 | command2`

Every Linux command generally has three streams:
-   **Standard Input (stdin):** Where the command receives its input (usually from the keyboard or a file).
-   **Standard Output (stdout):** Where the command sends its normal output (usually to the screen).
-   **Standard Error (stderr):** Where the command sends error messages (also usually to the screen).

The pipe `|` connects `stdout` of `command1` to `stdin` of `command2`.

```bash title="List files and send output to grep"
ls -l | grep "Dec"
```

**What happens:**
1.  `ls -l` lists the files in the current directory in long format.
2.  Instead of printing to your screen, the output of `ls -l` is "piped" to `grep`.
3.  `grep "Dec"` receives this output as its input and filters for lines containing "Dec".
4.  Only the matching lines are then printed to your screen.

This is a fundamental concept.

## Common Pipe Scenarios

### Filtering Output (`command | grep`)

One of the most frequent uses of pipes is to filter the output of a command.

```bash title="Find specific processes"
ps aux | grep "nginx"
```
This shows only the lines from the `ps aux` command (listing all running processes) that contain "nginx".

### Counting Filtered Results (`command | grep | wc -l`)

Once you've filtered, you often want to quantify.

```bash title="Count lines containing 'ERROR' in syslog"
cat /var/log/syslog | grep -i "ERROR" | wc -l
```
1.  `cat /var/log/syslog` outputs the entire log file.
2.  `grep -i "ERROR"` filters for case-insensitive "ERROR" lines.
3.  `wc -l` counts the lines received from `grep`.

This tells you exactly how many error lines are in your syslog.

### Extracting Specific Columns (`command | cut` or `command | awk`)

You have a structured output, and you need just one or two columns.

```bash title="Extract usernames from /etc/passwd"
cat /etc/passwd | cut -d ':' -f 1
```
1.  `cat /etc/passwd` outputs the password file.
2.  `cut -d ':' -f 1` takes that output and extracts the first field, using `:` as the delimiter.

**Using `awk` is often more robust for this:**
```bash title="Extract usernames with awk"
awk -F ':' '{print $1}' /etc/passwd
```
No `cat` needed here, as `awk` can read files directly (see "Useless Use of Cat" below).

### Searching History (`history | grep`)

Your shell keeps a history of commands you've typed.

```bash title="Find previous commands related to 'apt install'"
history | grep "apt install"
```

This lets you quickly find a command you ran previously without scrolling through a long history.

## Building Complex Pipelines: A Real-World Example

Let's say you want to find the top 5 most frequent IP addresses that accessed your web server from the `access.log`.

```bash title="Find top 5 IPs in access log"
awk '{print $1}' access.log | sort | uniq -c | sort -rn | head -5
```

**Breakdown of the pipeline:**
1.  `awk '{print $1}' access.log`: Extracts the first field (the IP address) from each line of `access.log`.
    *   *Output:* A list of IP addresses, one per line (many duplicates).
2.  `sort`: Sorts this list alphabetically. This is crucial because `uniq` *only* works on adjacent lines.
    *   *Output:* A sorted list of IP addresses (still with duplicates, but now adjacent).
3.  `uniq -c`: Counts the occurrences of each *unique* adjacent line and prepends the count.
    *   *Output:* `[count] [IP Address]` (e.g., `123 192.168.1.1`).
4.  `sort -rn`: Sorts the output numerically (`-n`) in reverse (`-r`) order. This places the highest counts at the top.
    *   *Output:* `[highest count] [IP]` to `[lowest count] [IP]`.
5.  `head -5`: Takes the first 5 lines from the sorted output, giving you the top 5 most frequent IPs.
    *   *Output:* The final top 5 IPs and their counts.

This single line of commands, chained together, performs a sophisticated data analysis task.

## Redirection: Sending Output Elsewhere

Pipes send output *from one command to another*. Redirection sends output *from a command to a file*, or takes input *from a file to a command*.

### Output Redirection (`>` and `>>`)

-   `>`: Overwrites a file with the command's standard output.
-   `>>`: Appends the command's standard output to the end of a file.

```bash title="Save a list of files to a file"
ls -l > file_list.txt
```
This creates `file_list.txt` containing the output of `ls -l`. If `file_list.txt` already exists, its contents are erased.

```bash title="Append new errors to an existing error log"
grep "critical" system.log >> critical_errors.log
```
This adds any lines containing "critical" from `system.log` to the end of `critical_errors.log`.

### Input Redirection (`<`)

Takes the contents of a file as standard input for a command.

```bash title="Sort the contents of file.txt"
sort < file.txt
```
This is often equivalent to just `sort file.txt`, but it's useful for commands that expect input from stdin.

### Redirecting Standard Error (`2>`)

By default, standard output and standard error both go to your terminal. You can redirect stderr separately.

```bash title="Redirect errors to a file"
find / -name "hosts" 2> errors.log
```
This runs `find` and sends any "Permission denied" or other error messages to `errors.log`, keeping your screen clean.

```bash title="Redirect errors to null (hide them)"
find / -name "hosts" 2> /dev/null
```
Sending stderr to `/dev/null` effectively silences error messages.

## `xargs`: Bridging the Gap (stdin to arguments)

Sometimes, a command expects its input as *arguments*, not as standard input. This is where `xargs` comes in. It takes items from standard input and builds and executes command lines from them.

### Basic `xargs` Usage

```bash title="Convert lines of input to arguments for 'echo'"
echo "file1.txt\nfile2.txt" | xargs echo "Processing:"
```

**Output:**
```
Processing: file1.txt file2.txt
```
`xargs` took "file1.txt" and "file2.txt" as separate lines of input, and passed them as arguments to `echo`.

### `find` with `xargs` (Safe Deletion)

`find` can generate a list of files, and `xargs` can then run a command on each of them.

```bash title="Find and delete all .bak files"
find . -name "*.bak" | xargs rm
```
This is safer than `rm *.bak` because it handles many files and files with special characters better.

!!! warning "Be careful with `xargs rm`!"
    Just like `rm`, `xargs rm` is permanent. Always test your `find` command first without `xargs rm` to ensure it lists the files you *actually* intend to delete. For example, run `find . -name "*.bak"` first.

### Handling Spaces in Filenames (`-print0` and `-0`)

The standard behavior of `xargs` can break if filenames contain spaces. The `-print0` option for `find` (which outputs null-terminated strings) combined with `xargs -0` (which reads null-terminated strings) solves this.

```bash title="Safely delete files with spaces in names"
find . -name "* with spaces.txt" -print0 | xargs -0 rm
```

### `xargs` with `mv` or `cp`

```bash title="Move all .jpg files to a new directory"
find . -name "*.jpg" -print0 | xargs -0 mv -t ~/pictures/
```
The `-t` option for `mv` (and `cp`) specifies the target directory.

## Common Mistakes

### Useless Use of Cat (UUOC)

Often, `cat` is piped to another command that can read files directly. This is unnecessary.

```bash
cat file.txt | grep "pattern"   # Useless use of cat
```
**Better:**
```bash
grep "pattern" file.txt         # Grep can read file directly
```

The exception is when you need `cat` to concatenate multiple files before piping.

```bash
cat file1.txt file2.txt | sort   # Here, cat is useful
```

### Forgetting to Quote Patterns

This is common with `grep` and `sed`. If your pattern contains spaces or shell special characters, always quote it.

```bash
# Problem: Shell interprets `*` before grep
grep *.log access.log

# Solution: Quote the pattern
grep "*.log" access.log
```

### Not Understanding Standard Input/Output

If a command expects arguments and you pipe to it, it might not work as expected. That's `xargs`'s job.

```bash
echo "file1.txt" | rm   # Fails. rm expects arguments, not stdin.
```
**Correct:**
```bash
echo "file1.txt" | xargs rm
```

### Incorrect Delimiters

When using `cut`, ensure you're using the correct delimiter, especially if it's not the default tab.

```bash
cut -f 1 data.csv      # Fails if data.csv is comma-separated
cut -d ',' -f 1 data.csv # Correct for CSV
```

## Practice Exercises

**Exercise 1: Basic Filtering and Counting**
How many lines in `/etc/passwd` contain the word "bash"?
```bash
grep "bash" /etc/passwd | wc -l
```

**Exercise 2: Extract and Sort Unique IPs**
From `/var/log/auth.log`, extract all IP addresses that attempted to log in, and show a sorted list of unique IPs.
*(Hint: Look for "from [IP_ADDRESS]")*
```bash
grep -oP 'from \K\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}' /var/log/auth.log | sort -u
```
*(Explanation of `grep -oP 'from \K...'`: `-o` prints only matching part, `-P` enables Perl regex, `\K` resets match start)*

**Exercise 3: Find and Replace in Files**
You have several configuration files in `~/configs/` and you need to change all occurrences of `OLD_DOMAIN` to `NEW_DOMAIN`.
*(Create some dummy files first: `mkdir ~/configs; echo "DOMAIN=OLD_DOMAIN" > ~/configs/app1.conf; echo "URL=http://OLD_DOMAIN" > ~/configs/app2.conf`)*
```bash
find ~/configs -type f -name "*.conf" -print0 | xargs -0 sed -i 's/OLD_DOMAIN/NEW_DOMAIN/g'
```
*(Verify with `grep -r NEW_DOMAIN ~/configs`)*

**Exercise 4: Log Analysis Pipeline**
From `/var/log/syslog`, count the number of log entries per day and display the top 5 days with the most entries.
```bash
awk '{print $1, $2}' /var/log/syslog | sort | uniq -c | sort -rn | head -5
```
*(This extracts Month and Day, sorts, counts unique Month-Day combinations, sorts by count, and shows top 5)*

## Key Takeaways

-   **Pipes (`|`)** connect `stdout` of one command to `stdin` of another.
-   **Redirection (`>`, `>>`, `<`)** sends output to/from files.
-   **`xargs`** converts `stdin` into arguments for commands.
-   **Combine simple tools** to build powerful data processing pipelines.
-   **Avoid Useless Use of Cat (`UUOC`)** - `command < file` or `command file` is usually better than `cat file | command`.
-   **Use `find ... -print0 | xargs -0 ...`** for safe handling of filenames with spaces.
-   **Error redirection (`2>`, `2>>`)** separates errors from normal output.

Mastering pipes and redirection is a huge leap in your Linux journey. It allows you to automate complex tasks with simple, composable commands. This is the essence of the "Unix philosophy": small, sharp tools, working together.

You're no longer just running commands; you're orchestrating them.

Let's keep building.

```