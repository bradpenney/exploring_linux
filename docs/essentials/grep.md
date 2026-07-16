---
date: "2026-02-03 21:52"
title: grep - Linux Text Search and Pattern Matching
description: Master grep for Linux — regular expressions, recursive search, context flags, and the real-world patterns every sysadmin uses for log analysis and system investigation.
---

# grep

!!! tip "Part of Essentials"
    This article covers `grep` in depth. It assumes you're comfortable with [pipes and redirection](pipes_and_redirection.md) — `grep` lives almost entirely inside pipelines.

Every production incident eventually comes down to the same question: *what does the log say?* And in Linux, the answer almost always involves `grep`. Whether you're searching a single file, recursively hunting through a config directory, or filtering live log output from `journalctl`, `grep` is the tool that cuts through the noise.

Learning to use `grep` well isn't about memorizing flags. It's about pattern thinking — knowing how to describe what you're looking for precisely enough that `grep` can find it.

---

## Where You've Seen This

You've used `grep`-equivalent tools without knowing it:

- **IDE find-in-files** (VS Code Ctrl+Shift+F, IntelliJ's "Find in Path") — same concept: search text matching a pattern across multiple files
- **SQL `WHERE column LIKE '%pattern%'`** — same concept: filter rows by pattern match
- **Splunk/Elasticsearch/Datadog search** — the search bar is a UI layer over the same operation: find log lines matching a pattern
- **Browser Ctrl+F** — single-file version

What `grep` adds over all of these: it's composable. You can pipe output *into* grep to filter it, or pipe grep's output *out* to further tools. That's what makes it the backbone of Linux investigation — it's not just a search tool, it's a filter that fits anywhere in a pipeline.

The regular expression syntax in `grep -E` is the same regex you use in Python, JavaScript, Java, Go, or any language. Learning it here pays off everywhere.

---

## The Core Idea

`grep` reads input line by line and prints lines that match a pattern. That's it. Its power comes from:

1. Flexible pattern language (regular expressions)
2. Composability with other commands via pipes
3. A rich set of flags for controlling what and how it matches

``` bash title="grep Basics"
grep "error" /var/log/syslog          # (1)!
journalctl | grep "Failed"            # (2)!
grep -r "database_host" /etc/myapp/   # (3)!
```

1. Search a file.
2. Filter a stream.
3. Search recursively.

---

## Essential Flags

<div class="grid cards" markdown>

-   :material-magnify: **Matching Control**

    ---

    ``` bash title="What to Match"
    grep -i "error" logfile           # (1)!
    grep -v "debug" logfile           # (2)!
    grep -w "fail" logfile            # (3)!
    grep -F "literal.string" file     # (4)!
    grep -E "pattern1|pattern2" file  # (5)!
    ```

    1. Case-insensitive (`-i`).
    2. Invert — exclude matching lines (`-v`).
    3. Whole word only (`-w`) — won't match "failure".
    4. Treat the pattern as literal, not regex (`-F`).
    5. Extended regex — OR matching (`-E`).

-   :material-format-list-numbered: **Output Format**

    ---

    ``` bash title="Controlling Output"
    grep -n "error" logfile         # (1)!
    grep -c "error" logfile         # (2)!
    grep -l "error" /var/log/*.log  # (3)!
    grep -L "error" /etc/*.conf     # (4)!
    grep -o "pattern" logfile       # (5)!
    grep -h "error" /var/log/*.log  # (6)!
    ```

    1. Show line numbers (`-n`).
    2. Count of matching lines (`-c`).
    3. Show only filenames (`-l`).
    4. Files that do **not** match (`-L`).
    5. Print only the matched part (`-o`).
    6. Suppress the filename in output (`-h`).

-   :material-text-search: **Context**

    ---

    ``` bash title="Show Surrounding Lines"
    grep -A 3 "error" logfile      # (1)!
    grep -B 3 "error" logfile      # (2)!
    grep -C 3 "error" logfile      # (3)!
    ```

    1. 3 lines **after** the match (`-A`).
    2. 3 lines **before** the match (`-B`).
    3. 3 lines on **both** sides (`-C`, context).

    **Key insight:** Context flags are essential for log analysis. An error line without context is often meaningless — you need to see what happened before and after.

-   :material-folder-search: **Recursive Search**

    ---

    ``` bash title="Search Directories"
    grep -r "pattern" /etc/                      # (1)!
    grep -rl "pattern" /etc/                     # (2)!
    grep -ri "pattern" /etc/                     # (3)!
    grep -r "pattern" --include="*.conf" /etc/   # (4)!
    grep -r "pattern" --exclude="*.log" /var/    # (5)!
    ```

    1. Search all files recursively (`-r`).
    2. Filenames only, recursive (`-rl`).
    3. Recursive + case-insensitive (`-ri`).
    4. Limit to `.conf` files.
    5. Skip log files.

</div>

---

## Regular Expressions

`grep`'s default mode uses Basic Regular Expressions (BRE). With `-E` (or `egrep`), you get Extended Regular Expressions (ERE) — more powerful and the version you'll use most.

### Anchors and Wildcards

``` bash title="Anchors"
grep "^error" logfile               # (1)!
grep "error$" logfile               # (2)!
grep "^$" logfile                   # (3)!
grep "^#" /etc/nginx.conf           # (4)!
grep -v "^#\|^$" /etc/nginx.conf    # (5)!
```

1. Lines **starting** with "error".
2. Lines **ending** with "error".
3. Empty lines.
4. Comment lines only.
5. Exclude comments and blank lines.

``` bash title="Wildcards"
grep "err.r" logfile        # (1)!
grep "err.*log" logfile     # (2)!
grep "colou\?r" logfile     # (3)!
grep -E "colou?r" logfile   # (4)!
```

1. `.` matches any single character.
2. `.*` matches any sequence of characters.
3. `\?` makes the previous character optional (BRE) — matches "color" and "colour".
4. ERE equivalent — no backslash needed.

### Character Classes

``` bash title="Character Classes"
grep "[0-9]" logfile           # (1)!
grep "[a-zA-Z]" logfile        # (2)!
grep "[[:digit:]]" logfile     # (3)!
grep "[[:alpha:]]" logfile     # (4)!
grep "[[:space:]]" logfile     # (5)!
grep "[^0-9]" logfile          # (6)!
```

1. Any digit.
2. Any letter.
3. POSIX class: any digit.
4. POSIX class: any letter.
5. POSIX class: whitespace.
6. `^` inside `[]` means NOT — any non-digit.

### Extended Regex: Quantifiers and Alternation

With `-E`, you get cleaner syntax and more quantifiers:

``` bash title="Extended Regex (-E)"
grep -E "error|warning|critical" logfile                          # (1)!
grep -E "err+" logfile                                            # (2)!
grep -E "err?" logfile                                            # (3)!
grep -E "err{2}" logfile                                          # (4)!
grep -E "err{2,4}" logfile                                        # (5)!
grep -E "(ERROR|error): (disk|memory)" logfile                    # (6)!
grep -E "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" logfile  # (7)!
```

1. Alternation — match any of these patterns.
2. `+` = one or more of the previous character.
3. `?` = zero or one of the previous character.
4. `{n}` = exactly n repetitions.
5. `{n,m}` = between n and m repetitions.
6. Group and alternate.
7. Matches lines starting with an IPv4 address pattern: 1–3 digits then a dot, four times. Not a perfect IP validator, but useful for extracting IP lines from logs.

### Fixed String Mode (-F)

When your search pattern contains regex special characters (`.`, `*`, `[`, `(`, etc.) that you want to treat literally, use `-F`:

``` bash title="Literal String Search"
grep -F "2.5.0.1" /etc/hosts          # (1)!
grep -F "user[admin]" config.txt      # (2)!
grep -F "price: $9.99" catalog.txt    # (3)!
```

1. Searches for the literal `2.5.0.1`, not a regex — the dots are treated literally.
2. Literal brackets, not a character class.
3. Literal `$` and `.`.

Without `-F`, `grep "2.5.0.1"` would match "250001" (the dots match any character). Use `-F` when searching for version strings, IP addresses, file paths, or any literal text.

---

## grep in the Real World

### Log Analysis Patterns

``` bash title="Production Log Investigation"
journalctl --since "1 hour ago" | grep -i "error\|fail\|critical" -A 2                     # (1)!
grep -oE "(ERROR|WARNING|CRITICAL)" /var/log/myapp/app.log | sort | uniq -c | sort -nr     # (2)!
grep "user=jsmith" auth.log | grep "FAILED"                                                # (3)!
grep -E " (4[0-9]{2}|5[0-9]{2}) " /var/log/nginx/access.log                                # (4)!
grep "Restart" /var/log/syslog | tail -1                                                   # (5)!
grep -B 5 -A 10 "OutOfMemoryError" /var/log/myapp/app.log                                   # (6)!
```

1. Find errors from the last hour, with 2 lines of trailing context.
2. Count errors by type, most frequent first.
3. Find lines matching multiple patterns (must match all).
4. Find specific HTTP status codes (4xx/5xx) in the access log.
5. Find the last occurrence of a pattern.
6. Show context around an error for diagnosis.

### Configuration File Analysis

``` bash title="Working with Config Files"
grep -v "^#\|^$" /etc/ssh/sshd_config                   # (1)!
grep -w "PermitRootLogin" /etc/ssh/sshd_config          # (2)!
grep -rl "db-prod-01" /etc/                             # (3)!
grep -v "^#" /etc/nginx/nginx.conf | grep -i "listen"   # (4)!
grep -r "ssl_certificate" /etc/nginx/                   # (5)!
```

1. Show the effective config — exclude comments and blank lines.
2. Check if a specific setting is enabled (`-w` matches whole words).
3. Find which config files reference a hostname.
4. Find all uncommented `listen` directives.
5. Check for a setting across multiple config files.

### Process and System Filtering

``` bash title="Filtering System Output"
ps aux | grep "[n]ginx"                                  # (1)!
df -h | grep -v "tmpfs\|devtmpfs\|udev"                  # (2)!
systemctl list-units | grep "failed"                     # (3)!
ss -tlnp | grep "LISTEN"                                 # (4)!
grep -v "nologin\|/bin/false" /etc/passwd | cut -d: -f1  # (5)!
```

1. The bracket trick `[n]ginx` matches "nginx" but not the `grep` process itself — `grep` shows up in `ps` as `[n]ginx`, which doesn't match its own pattern. A common solution to the "grep shows itself" problem.
2. Filter `df` output to real filesystems only.
3. Find services in a specific (failed) state.
4. Check which ports are listening.
5. Find users with real login shells.

---

## Common Scenarios

=== "Something Is Failing: Find the Error"

    You know something's wrong but not what. Start broad, narrow down.

    ``` bash title="Error Investigation Workflow"
    # Step 1: Find recent errors
    journalctl --since "1 hour ago" | grep -i "error\|fail" | head -30

    # Step 2: Find the specific service's logs
    journalctl -u nginx --since "1 hour ago" | grep -i "error" -B 3 -A 5

    # Step 3: If it's a file-based log, same approach
    grep -i "error" /var/log/nginx/error.log | tail -50

    # Step 4: Once you spot an error, get more context
    grep -n "upstream timed out" /var/log/nginx/error.log | tail -5
    # note the line number, then:
    grep -A 20 "upstream timed out" /var/log/nginx/error.log | tail -25
    ```

=== "Config Change: What's Actually Set?"

    After editing config files, verify what's actually active:

    ``` bash title="Verifying Configuration"
    # See all non-comment, non-empty lines
    grep -v "^[[:space:]]*#\|^[[:space:]]*$" /etc/nginx/nginx.conf

    # Check a specific setting across all included files
    grep -r "worker_processes" /etc/nginx/

    # Verify SSL settings
    grep -r "ssl_" /etc/nginx/ | grep -v ".conf:#"

    # Compare two config files
    grep -F -x -f expected.conf actual.conf   # lines in both files
    ```

=== "Security Audit: Find Suspicious Patterns"

    Looking for signs of unauthorized access or misconfiguration:

    ``` bash title="Security Investigation"
    # Failed SSH login attempts
    grep "Failed password" /var/log/auth.log | tail -50

    # Successful logins from unexpected IPs
    grep "Accepted password" /var/log/auth.log | awk '{print $11}' | sort | uniq -c

    # World-writable files (via find output)
    find /etc -type f 2>/dev/null | xargs grep -l "" 2>/dev/null | head -5

    # Check for root logins
    grep "session opened for user root" /var/log/auth.log

    # Find cron jobs being added
    grep "CRON" /var/log/syslog | grep "CMD" | tail -20
    ```

=== "Find Which File Contains Something"

    You know a setting exists somewhere, but not which file:

    ``` bash title="Hunting for Config Values"
    # Which file in /etc references a database hostname?
    grep -rl "db-prod-01" /etc/ 2>/dev/null

    # Which config file sets a specific IP?
    grep -r "192.168.10.50" /etc/ 2>/dev/null

    # Which log files contain a specific error code?
    grep -rl "ORA-01017" /var/log/ 2>/dev/null

    # Once you find the file, get context
    grep -n "db-prod-01" /etc/myapp/config.yml -B 2 -A 2
    ```

---

## Quick Reference

### Essential Flag Combinations

| Pattern | Use Case |
|---------|---------|
| `grep -i "error" file` | Case-insensitive search |
| `grep -v "debug" file` | Exclude lines matching pattern |
| `grep -c "error" file` | Count matches |
| `grep -n "error" file` | Show line numbers |
| `grep -l "error" *.log` | Filenames with matches |
| `grep -r "setting" /etc/` | Recursive directory search |
| `grep -rl "setting" /etc/` | Recursive, filenames only |
| `grep -A 5 "error" file` | Match plus 5 lines after |
| `grep -B 5 "error" file` | Match plus 5 lines before |
| `grep -C 5 "error" file` | Match plus 5 lines each side |
| `grep -E "a\|b" file` | Match either pattern |
| `grep -w "fail" file` | Whole word only |
| `grep -F "1.2.3.4" file` | Literal string (no regex) |
| `grep -v "^#\|^$" file` | Remove comments and blank lines |

### Common Regex Patterns

| Pattern | Matches |
|---------|---------|
| `^word` | Lines starting with "word" |
| `word$` | Lines ending with "word" |
| `^$` | Empty lines |
| `word.` | "word" followed by any character |
| `word.*end` | "word" then anything then "end" |
| `[0-9]` | Any digit |
| `[[:digit:]]` | Any digit (POSIX) |
| `-E "a\|b"` | Either "a" or "b" |
| `-E "err+"` | "er" then one or more "r" |
| `-E "[0-9]{3}"` | Exactly three digits |

---

## Practice Exercises

??? question "Exercise 1: Multi-Flag Combination"
    In `/var/log/auth.log` (or `/var/log/secure`):

    1. Find all lines containing "Failed" (case-insensitive)
    2. Show the 2 lines after each match for context
    3. Count how many total matches there are

    ??? tip "Solution"
        ``` bash title="Auth Log Investigation"
        # With context
        grep -i "failed" /var/log/auth.log -A 2

        # Count matches
        grep -ic "failed" /var/log/auth.log

        # Or show with context AND count separately
        grep -i "failed" /var/log/auth.log -A 2 | tee /tmp/failed.txt | wc -l
        ```

??? question "Exercise 2: Config File Cleanup"
    Show the "effective" configuration from `/etc/ssh/sshd_config` — only lines that are actually set (no comment lines, no blank lines).

    ??? tip "Solution"
        ``` bash title="Effective Config View"
        grep -v "^[[:space:]]*#\|^[[:space:]]*$" /etc/ssh/sshd_config
        ```

        `^[[:space:]]*#` matches lines that start with optional whitespace then `#` (comment lines). `^[[:space:]]*$` matches lines containing only whitespace (blank lines). The `-v` inverts to exclude both.

??? question "Exercise 3: Process Filter"
    List all running processes containing "python" in their command, but exclude the grep process itself from the results.

    ??? tip "Solution"
        ``` bash title="Process Filter Without Self-Match"
        ps aux | grep "[p]ython"
        # The [p]ython trick: grep's own process shows as "[p]ython" which doesn't match "python"
        ```

        Or alternatively:

        ``` bash title="Alternative: pgrep"
        pgrep -la python
        # pgrep is designed for this purpose — no self-match issue
        ```

??? question "Exercise 4: Find Files Containing Multiple Patterns"
    Find all `.conf` files in `/etc/` that contain *both* the word "ssl" AND the word "certificate".

    ??? tip "Solution"
        ``` bash title="Files Matching Multiple Patterns"
        grep -rl "ssl" /etc/ --include="*.conf" 2>/dev/null \
          | xargs grep -l "certificate" 2>/dev/null
        ```

        First `grep -rl` finds files containing "ssl". Then `xargs grep -l` filters those results to only files also containing "certificate". The two-stage approach handles AND logic, which `grep` alone can't do directly.

---

## Quick Recap

- **Default grep:** BRE patterns, case-sensitive, prints matching lines
- **`-E`:** Extended regex for `|`, `+`, `?`, `{n}` without backslashes — use this almost always
- **`-i`:** Case-insensitive; **`-v`:** invert; **`-w`:** whole word; **`-F`:** literal string
- **`-r`:** recursive directory search; **`-l`:** filenames only; **`-n`:** line numbers
- **`-A/-B/-C`:** context lines — essential for log analysis
- **`-c`:** count; **`-o`:** print only matched part
- **Config trick:** `grep -v "^#\|^$"` removes comments and blank lines — use constantly
- **Process trick:** `[p]attern` in brackets prevents grep from matching itself

## What's Next?

You can search text. Now you need to understand what's *running* on the system — which processes exist, what resources they consume, and how to manage them.

Head to **[Processes](processes.md)** to learn how Linux manages running programs: process IDs, signals, process states, and the commands every sysadmin uses to investigate and control what's happening on a system.

---

## Further Reading

### Command References

- `man grep` — complete reference including all flags and regex syntax
- `man 7 regex` — POSIX regular expression specification
- `man egrep` — extended grep (same as `grep -E`)

### Deep Dives

- [Regular Expressions Info](https://www.regular-expressions.info/) — comprehensive regex tutorial and reference
- [The Art of Command Line: Data Wrangling](https://github.com/jlevy/the-art-of-command-line#data-wrangling) — grep patterns in real workflows
- [Grep Cookbook](https://www.digitalocean.com/community/tutorials/using-grep-regular-expressions-to-search-for-text-patterns-in-linux) — practical grep examples

### Official Documentation

- [GNU grep Manual](https://www.gnu.org/software/grep/manual/grep.html) — the authoritative grep reference
- [Red Hat: grep Command Examples](https://www.redhat.com/sysadmin/find-text-files-using-grep) — RHEL-specific grep guide
- [Arch Wiki: grep](https://wiki.archlinux.org/title/grep) — concise grep reference with examples

