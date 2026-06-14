---
date: "2026-02-03 21:52"
title: Pipes and Redirection in Linux - Building Command Pipelines
description: Master Linux pipes and redirection — combine commands into powerful pipelines, redirect output to files, and manage stdin, stdout, and stderr like a pro.
---

# Pipes and Redirection

!!! tip "Part of Essentials"
    This article assumes you're comfortable with basic commands and [command chaining](command_line_fundamentals.md#command-chaining) (`&&`, `||`). Pipes are related but different — they connect command *output* to command *input*, not just sequence execution.

The most powerful Linux one-liners you'll ever see don't use a single complex command. They use simple commands connected together. `cat access.log | grep "500" | awk '{print $1}' | sort | uniq -c | sort -nr | head -10` — that's ten minutes of investigation distilled to one line, and each part is a simple tool you already know.

That's the Unix philosophy in action: programs that do one thing well, connected by pipes. This article shows you how to connect them.

---

## Where You've Seen This

If you've used PowerShell, you know pipes — `Get-Process | Where-Object CPU -gt 10 | Sort-Object CPU -Descending`. The Linux version works the same way conceptually, but passes plain text instead of objects. That difference matters: Linux pipelines are more composable (any tool can talk to any other tool), but you work with structured text rather than typed objects.

If you've built ETL pipelines, data workflows, or streaming architectures — Kafka, Spark, Logstash — the stdin/stdout model is the same idea at shell scale. Data flows from source through transformations to sink. Each command is a transform.

Redirection (`>`, `>>`, `2>`) is the command-line equivalent of writing to a file in any language. You've done this before; the Linux operators are just a more concise syntax.

---

## Standard Streams: The Foundation

Every process in Linux has three data channels open by default:

``` mermaid
graph LR
    STDIN["📥 stdin (0)\nStandard Input\n← Keyboard or pipe"] --> PROCESS["⚙️ Command\nor Process"]
    PROCESS --> STDOUT["📤 stdout (1)\nStandard Output\n→ Screen or redirect"]
    PROCESS --> STDERR["⚠️ stderr (2)\nStandard Error\n→ Screen or redirect"]

    style STDIN fill:#2d3748,stroke:#63b3ed,stroke-width:2px,color:#fff
    style PROCESS fill:#d69e2e,stroke:#cbd5e0,stroke-width:2px,color:#000
    style STDOUT fill:#2d3748,stroke:#68d391,stroke-width:2px,color:#fff
    style STDERR fill:#2d3748,stroke:#fc8181,stroke-width:2px,color:#fff
```

| Stream | Number | Default | What Goes Here |
|--------|--------|---------|----------------|
| **stdin** | 0 | Keyboard | Input to commands |
| **stdout** | 1 | Terminal | Normal output |
| **stderr** | 2 | Terminal | Error messages |

By default, stdout and stderr both print to your terminal mixed together. Redirection and pipes give you control over each stream separately.

---

## Redirection: To and From Files

Redirection changes where a stream goes — from the terminal to a file, or from a file to a command's input.

<div class="grid cards" markdown>

-   :material-arrow-right: **Output Redirection (>)**

    ---

    **Why it matters:** Capture command output to a file for logging, later processing, or sharing with others.

    ``` bash title="Redirect stdout to a File"
    ls -lh /var/log/ > filelist.txt     # create/overwrite
    df -h > disk-report.txt
    ```

    !!! warning "> Overwrites Without Warning"
        `>` will silently overwrite an existing file. There's no confirmation. If `report.txt` existed, it's gone.

        To protect against this in interactive sessions:
        ``` bash title="Prevent Overwrite with noclobber"
        set -o noclobber    # add to ~/.bashrc
        ls > existing.txt   # now fails with "cannot overwrite existing file"
        ls >| existing.txt  # force overwrite when noclobber is set
        ```

-   :material-arrow-right-box: **Append Redirection (>>)**

    ---

    **Why it matters:** Add to an existing file without overwriting it. The essential operator for log files and accumulating data.

    ``` bash title="Append to a File"
    echo "Deployment started at $(date)" >> deploy.log
    df -h >> disk-history.txt   # build a history over time

    # Running multiple commands and collecting all output
    echo "=== $(date) ===" >> report.txt
    uptime >> report.txt
    free -h >> report.txt
    df -h >> report.txt
    ```

-   :material-arrow-left: **Input Redirection (<)**

    ---

    **Why it matters:** Feed a file into a command's stdin instead of typing. Less common in interactive use, but appears in scripts.

    ``` bash title="Redirect File to stdin"
    sort < names.txt          # sort the contents of names.txt
    wc -l < access.log        # count lines in access.log
    mysql -u root -p mydb < schema.sql   # feed SQL to mysql
    ```

-   :material-alert: **stderr Redirection (2>)**

    ---

    **Why it matters:** Error messages and normal output are separate streams. When you redirect with `>`, errors still print to the terminal. Use `2>` to capture them separately.

    ``` bash title="Redirect stderr"
    find / -name "hosts" 2>/dev/null      # discard errors, keep results
    find / -name "hosts" 2>errors.txt     # save errors to file
    command > output.txt 2> errors.txt    # separate stdout and stderr
    command > all.txt 2>&1               # (1)! combine both to one file
    ```

    1. `2>&1` redirects stderr (2) to wherever stdout (1) is currently going. Order matters: `> all.txt 2>&1` works; `2>&1 > all.txt` does not (the latter redirects stderr to the terminal, then redirects stdout to the file).

</div>

### Combining Redirections

``` bash title="Multiple Redirections in Practice"
# Capture output to file AND show it on screen simultaneously
# (tee reads stdin and writes to both stdout and a file)
find /var/log -name "*.log" | tee found-logs.txt

# Run a long job, save output, discard errors
./long-running-script.sh > results.txt 2>/dev/null

# Save both stdout and stderr to the same file
./deployment.sh > deploy.log 2>&1

# Save stderr to one file, stdout to another
./script.sh > output.log 2> errors.log
```

### Here Documents and Here Strings

For feeding multi-line input to commands:

``` bash title="Here Documents"
# Feed multiple lines to a command
cat << EOF > /etc/myapp/config.conf
[database]
host = db-prod-01
port = 5432
name = myapp_db
EOF

# Common for creating config files in scripts
sudo tee /etc/nginx/sites-available/myapp << EOF
server {
    listen 80;
    server_name myapp.example.com;
    root /var/www/myapp;
}
EOF
```

``` bash title="Here String (<<<)"
# Feed a single string to stdin
grep "pattern" <<< "string to search in"

# Practical: feed a variable to a command expecting stdin
base64 <<< "encode this text"
```

---

## Pipes: Command to Command

A **pipe** (`|`) takes the stdout of the left command and feeds it as stdin to the right command. No intermediate file, no waiting — it's streaming.

``` bash title="Your First Pipeline"
ls -lh /var/log/ | less
# ls outputs the directory listing
# | sends it to less
# less lets you scroll through it
```

### Building Pipelines

Pipelines chain as many commands as you need:

``` bash title="Growing a Pipeline"
# Start simple
cat /var/log/nginx/access.log

# Filter to 500 errors only
cat /var/log/nginx/access.log | grep " 500 "

# Extract just the IP addresses
cat /var/log/nginx/access.log | grep " 500 " | awk '{print $1}'

# Sort them
cat /var/log/nginx/access.log | grep " 500 " | awk '{print $1}' | sort

# Count occurrences of each IP
cat /var/log/nginx/access.log | grep " 500 " | awk '{print $1}' | sort | uniq -c

# Sort by count, most first
cat /var/log/nginx/access.log | grep " 500 " | awk '{print $1}' | sort | uniq -c | sort -nr

# Show only the top 10
cat /var/log/nginx/access.log | grep " 500 " | awk '{print $1}' | sort | uniq -c | sort -nr | head -10
```

This is how investigation pipelines get built — one stage at a time, checking the output at each step.

### The Essential Pipeline Tools

These commands exist primarily to work within pipelines:

<div class="grid cards" markdown>

-   :material-filter: **grep — Filter Lines**

    ---

    Filter a stream to only lines matching a pattern. Covered in depth in the [grep article](grep.md).

    ``` bash title="grep in Pipelines"
    journalctl | grep "Failed"
    ps aux | grep nginx
    cat /etc/passwd | grep -v "nologin"    # exclude service accounts
    ```

-   :material-sort: **sort — Sort Lines**

    ---

    Sort lines alphabetically or numerically.

    ``` bash title="sort in Pipelines"
    cat names.txt | sort              # alphabetical
    du -sh /var/* | sort -hr          # human-readable, largest first
    cat numbers.txt | sort -n         # numeric sort
    cat file.txt | sort -u            # sort and remove duplicates
    ```

-   :material-counter: **uniq — Remove Duplicates / Count**

    ---

    Remove consecutive duplicate lines, or count their occurrences. Works best after `sort`.

    ``` bash title="uniq in Pipelines"
    cat file.txt | sort | uniq               # unique lines only
    cat file.txt | sort | uniq -c            # count occurrences
    cat file.txt | sort | uniq -d            # only lines that appear more than once
    ```

-   :material-calculator: **wc — Count**

    ---

    Count lines, words, or characters.

    ``` bash title="wc in Pipelines"
    ls /etc | wc -l                     # how many files in /etc?
    cat access.log | grep "404" | wc -l  # how many 404 errors?
    cat file.txt | wc -c                 # how many bytes?
    ```

</div>

<div class="grid cards" markdown>

-   :material-table: **awk — Extract Fields**

    ---

    Extract specific columns from structured text. The most powerful field processor in the pipeline toolkit.

    ``` bash title="awk in Pipelines"
    ps aux | awk '{print $1, $2}'         # print user and PID columns
    df -h | awk '{print $1, $5}'          # filesystem and usage %
    cat /etc/passwd | awk -F: '{print $1, $3}'  # username and UID
    ```

-   :material-scissors-cutting: **cut — Extract Columns**

    ---

    Extract specific columns or character positions from fixed-format output.

    ``` bash title="cut in Pipelines"
    cat /etc/passwd | cut -d: -f1         # extract first field (username)
    cat /etc/passwd | cut -d: -f1,3       # username and UID
    ls -l | cut -c1-10                    # first 10 characters of each line
    ```

-   :material-magnify: **tee — Split Output**

    ---

    Write to a file AND pass through to the next pipe. Essential when you want to save intermediate results.

    ``` bash title="tee in Pipelines"
    find /var/log -name "*.log" | tee found-logs.txt | wc -l
    # saves the file list AND prints the count

    command | tee output.txt | grep "ERROR"
    # saves everything to output.txt, passes only errors downstream
    ```

-   :material-arrow-up-down: **head / tail — Limit Output**

    ---

    Take only the first or last N lines. Ubiquitous at the end of pipelines.

    ``` bash title="head and tail in Pipelines"
    ps aux | sort -k3 -nr | head -5      # top 5 CPU consumers
    ls -lt /var/log/ | head -10          # 10 most recently modified logs
    cat access.log | tail -100           # last 100 lines
    ```

</div>

### stderr in Pipelines

A critical detail: **pipes only carry stdout**. stderr bypasses the pipe and goes directly to the terminal.

``` bash title="Stderr Bypasses Pipes"
find / -name "*.conf" | wc -l
# Errors print to screen; only successful results go to wc
```

To include stderr in a pipeline:

``` bash title="Including stderr in Pipelines"
find / -name "*.conf" 2>&1 | wc -l    # count everything including error lines
find / -name "*.conf" 2>/dev/null | wc -l   # suppress errors, count only results
```

---

## Real-World Pipeline Patterns

=== "Log Analysis"

    Find the most common errors in the past hour:

    ``` bash title="Log Analysis Pipeline"
    # What IP addresses are causing the most 404s?
    grep " 404 " /var/log/nginx/access.log \
      | awk '{print $1}' \
      | sort | uniq -c \
      | sort -nr \
      | head -10

    # How many errors per hour in the last day?
    journalctl --since "24 hours ago" --until now \
      | grep -i "error" \
      | awk '{print $1, $2, substr($3,1,2)}' \
      | sort | uniq -c
    ```

=== "Process Investigation"

    Find what's consuming resources:

    ``` bash title="Process Investigation Pipeline"
    # Top 5 memory consumers (human-readable)
    ps aux --sort=-%mem | head -6

    # All processes owned by www-data
    ps aux | grep "^www-data"

    # Find processes listening on a port
    ss -tlnp | grep ":8080"

    # How many connections per state?
    ss -s | grep "TCP:"
    ```

=== "Disk Space Investigation"

    Find what's eating disk:

    ``` bash title="Disk Analysis Pipeline"
    # Largest directories in /var
    du -sh /var/* 2>/dev/null | sort -hr | head -10

    # Largest files anywhere on the system
    find / -type f -size +100M 2>/dev/null \
      | xargs ls -lh 2>/dev/null \
      | sort -k5 -hr \
      | head -10

    # Which log files grew today?
    find /var/log -name "*.log" -newer /var/log -type f \
      | xargs ls -lh 2>/dev/null \
      | sort -k5 -hr
    ```

=== "Config File Work"

    Process configuration files:

    ``` bash title="Config Processing Pipeline"
    # Find all uncommented settings in a config file
    grep -v "^#" /etc/ssh/sshd_config | grep -v "^$"

    # Find all unique setting names
    grep -v "^#" /etc/ssh/sshd_config \
      | grep -v "^$" \
      | awk '{print $1}' \
      | sort -u

    # Check if a setting is enabled
    grep -v "^#" /etc/ssh/sshd_config | grep "PermitRootLogin"
    ```

---

## Quick Reference

### Redirection Operators

| Operator | What It Does | Example |
|----------|-------------|---------|
| `>` | Redirect stdout to file (overwrite) | `ls > files.txt` |
| `>>` | Redirect stdout to file (append) | `echo "line" >> log.txt` |
| `<` | Redirect file to stdin | `sort < names.txt` |
| `2>` | Redirect stderr to file | `find / 2>/dev/null` |
| `2>&1` | Redirect stderr to stdout | `command > all.txt 2>&1` |
| `&>` | Redirect both stdout and stderr | `command &> all.txt` |
| `\|` | Pipe stdout to next command | `ls \| grep ".conf"` |
| `\| tee` | Write to file and pass through | `cmd \| tee file.txt \| wc -l` |

### Pipeline Toolkit

| Command | What It Does in Pipelines |
|---------|--------------------------|
| `grep pattern` | Keep only lines matching pattern |
| `grep -v pattern` | Remove lines matching pattern |
| `sort` | Sort lines alphabetically |
| `sort -n` | Sort numerically |
| `sort -hr` | Sort human-readable sizes, largest first |
| `uniq` | Remove consecutive duplicates |
| `uniq -c` | Count occurrences |
| `wc -l` | Count lines |
| `head -N` | Keep first N lines |
| `tail -N` | Keep last N lines |
| `awk '{print $N}'` | Extract Nth field |
| `cut -d: -f1` | Extract field by delimiter |
| `tee file.txt` | Write to file and pass through |

---

## Practice Exercises

??? question "Exercise 1: Build a Log Analysis Pipeline"
    Using `/var/log/auth.log` (or `/var/log/secure` on RHEL), build a pipeline that:

    1. Shows only lines containing "Failed"
    2. Extracts the source IP address (the IP after "from" in the line)
    3. Counts how many failed attempts per IP
    4. Sorts by count, highest first
    5. Shows the top 5 offenders

    ??? tip "Solution"
        ``` bash title="Log Analysis Pipeline"
        grep "Failed" /var/log/auth.log \
          | awk '/from/{print $(NF-3)}' \
          | sort \
          | uniq -c \
          | sort -nr \
          | head -5
        ```

        The `awk` pattern prints the field 3 from the end (`NF-3`) — on typical auth.log "Failed password" lines, this is the IP address.

??? question "Exercise 2: Redirect and Tee"
    Run a disk space analysis (`du -sh /var/* 2>/dev/null`) that:

    1. Saves the complete output to `/tmp/disk-report.txt`
    2. Simultaneously shows only entries larger than 1GB on the terminal

    ??? tip "Solution"
        ``` bash title="tee with Filtering"
        du -sh /var/* 2>/dev/null | tee /tmp/disk-report.txt | grep "^[0-9]*G"
        ```

        `tee` saves everything to the file; the pipe after `tee` sends the same data to `grep`, which filters for lines starting with a size in gigabytes.

??? question "Exercise 3: Separate stdout and stderr"
    Run `find / -name "sshd_config"` and:

    1. Save only the successful results (stdout) to `/tmp/found.txt`
    2. Discard all "Permission denied" errors (stderr)
    3. Print the count of found files to the terminal

    ??? tip "Solution"
        ``` bash title="Separate Streams"
        find / -name "sshd_config" 2>/dev/null > /tmp/found.txt
        wc -l < /tmp/found.txt

        # Or in one pipeline:
        find / -name "sshd_config" 2>/dev/null | tee /tmp/found.txt | wc -l
        ```

---

## Quick Recap

- **Three streams:** stdin (0), stdout (1), stderr (2) — redirect each independently
- **`>`** overwrites; **`>>`** appends — the most common mistake is using `>` when you meant `>>`
- **`2>/dev/null`** — silence errors; ubiquitous in `find` and other commands that hit permission-denied directories
- **`2>&1`** — merge stderr into stdout; essential when capturing all output to a file
- **`|`** pipes only stdout — to include stderr, add `2>&1` before the pipe
- **Build pipelines incrementally** — add one stage at a time, verify output, then extend
- **Core toolkit:** `grep`, `sort`, `uniq -c`, `wc -l`, `head`, `tail`, `awk`, `tee`

---

## Further Reading

### Command References

- `man bash` — the "Redirection" section covers every redirect operator
- `man tee` — the tee command in detail
- `man awk` — the full awk reference (also `man gawk` for GNU awk)
- `man sort` — sort options including locale-aware and stable sorting
- `man uniq` — uniq options

### Deep Dives

- [The Art of Command Line: Data Wrangling](https://github.com/jlevy/the-art-of-command-line#data-wrangling) — practical pipeline patterns
- [Bash Redirections Cheat Sheet](https://wiki.bash-hackers.org/howto/redirection_tutorial) — Bash Hackers Wiki on redirection
- [Unix Philosophy](https://en.wikipedia.org/wiki/Unix_philosophy) — why pipes exist and why they work

### Official Documentation

- [GNU Coreutils Manual](https://www.gnu.org/software/coreutils/manual/) — sort, uniq, wc, tee, head, tail
- [GNU Bash Manual: Redirections](https://www.gnu.org/software/bash/manual/bash.html#Redirections) — complete redirect reference

---

## What's Next?

Pipes flow data between commands, and the most common thing you'll do with that data is search it. `grep` is the workhorse of Linux text processing — and it deserves its own deep dive.

Head to **[grep](grep.md)** to learn regular expressions, recursive searching, context flags, and the patterns that turn `grep` from a simple filter into a powerful investigation tool.
