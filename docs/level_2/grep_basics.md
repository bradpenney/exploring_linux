# Searching Inside Files

!!! quote "Finding needles in haystacks - the grep command"

## The Search Problem

You've got thousands of files. Configuration files, log files, code files, documentation. Somewhere in there is the information you need - an error message, a configuration setting, a function definition, an IP address.

**Clicking through files one by one? That's madness.**

Enter `grep` - Global Regular Expression Print. It searches file contents for patterns and shows you matching lines. It's fast, powerful, and once you learn it, you'll use it daily.

## Basic grep

The simplest form:

```bash title="Search for a word in a file"
grep "error" logfile.txt
```

This shows every line in `logfile.txt` containing the word "error".

**Output:**
```
2024-12-14 10:23:15 ERROR: Connection failed
2024-12-14 10:25:42 ERROR: Database timeout
2024-12-14 11:05:18 ERROR: File not found
```

**Search multiple files:**

```bash title="Search all .txt files"
grep "TODO" *.txt
```

**Output:**
```
notes.txt:TODO: Review this section
tasks.txt:TODO: Call the client
readme.txt:TODO: Update installation instructions
```

File names are shown before each match.

**Search recursively through directories:**

```bash title="Search all files in current directory and subdirectories"
grep -r "database" .
```

The `-r` (recursive) flag searches every file in the current directory (`.`) and all subdirectories.

## Case Sensitivity

By default, grep is case-sensitive:

```bash
grep "Error" logfile.txt    # Finds "Error" but not "error" or "ERROR"
```

**Case-insensitive search:**

```bash title="Search regardless of case"
grep -i "error" logfile.txt
```

Now it finds "error", "Error", "ERROR", "ErRoR", etc.

## Show Context Around Matches

Seeing just the matching line isn't always enough. You need context.

**Show lines after match:**

```bash title="Show 3 lines after each match"
grep -A 3 "error" logfile.txt
```

**Show lines before match:**

```bash title="Show 3 lines before each match"
grep -B 3 "error" logfile.txt
```

**Show lines before and after:**

```bash title="Show 3 lines before and after"
grep -C 3 "error" logfile.txt
```

**Example output:**
```
2024-12-14 10:23:10 INFO: Starting process
2024-12-14 10:23:12 INFO: Connecting to database
2024-12-14 10:23:13 WARN: Connection slow
2024-12-14 10:23:15 ERROR: Connection failed
2024-12-14 10:23:16 INFO: Retrying connection
2024-12-14 10:23:17 INFO: Connection established
2024-12-14 10:23:18 INFO: Process complete
```

Context helps you understand what led to the error.

## Show Line Numbers

**Include line numbers in output:**

```bash title="Show which line number matches appear on"
grep -n "error" logfile.txt
```

**Output:**
```
15:2024-12-14 10:23:15 ERROR: Connection failed
42:2024-12-14 10:25:42 ERROR: Database timeout
87:2024-12-14 11:05:18 ERROR: File not found
```

Now you can jump to line 15, 42, or 87 in your editor.

**Combine with context:**

```bash
grep -n -C 2 "error" logfile.txt
```

Shows line numbers with 2 lines of context before and after.

## Count Matches

**How many lines match?**

```bash title="Count matching lines"
grep -c "error" logfile.txt
```

**Output:**
```
3
```

**Count in multiple files:**

```bash
grep -c "TODO" *.txt
```

**Output:**
```
notes.txt:5
tasks.txt:12
readme.txt:2
```

## Invert Match (Show Non-Matching Lines)

**Show lines that DON'T contain a pattern:**

```bash title="Show lines without 'error'"
grep -v "error" logfile.txt
```

Useful for filtering out noise:

```bash title="Show logs excluding INFO messages"
grep -v "INFO" logfile.txt
```

## Search for Whole Words Only

```bash
grep "port" config.txt
```

This matches "port", "report", "import", "support", etc.

**Match whole words only:**

```bash title="Match 'port' as complete word"
grep -w "port" config.txt
```

Now it only matches "port", not "report" or "support".

## List Files With Matches

**Just show which files contain matches, not the matches themselves:**

```bash title="List filenames containing 'error'"
grep -l "error" *.log
```

**Output:**
```
app.log
database.log
system.log
```

**Opposite - show files WITHOUT matches:**

```bash title="List files NOT containing 'error'"
grep -L "error" *.log
```

## Multiple Patterns

**Search for multiple patterns (OR logic):**

```bash title="Find lines with 'error' OR 'warning'"
grep -E "error|warning" logfile.txt
```

The `-E` flag enables extended regex. The `|` means OR.

**Alternative syntax:**

```bash
grep "error\|warning" logfile.txt
```

**Match if line contains BOTH patterns:**

```bash
grep "error" logfile.txt | grep "database"
```

This finds lines containing both "error" AND "database".

## Practical Examples

### Find Configuration Settings

```bash title="Find database host in config files"
grep -r "db_host" /etc/myapp/
```

### Find Function Definitions in Code

```bash title="Find where function is defined"
grep -rn "def calculate_total" .
```

The `-n` shows line numbers so you can jump to the definition.

### Find Recent Errors in Logs

```bash title="Find errors in system log"
sudo grep -i "error" /var/log/syslog
```

### Find IP Addresses

```bash title="Find lines with IP addresses"
grep -E "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" access.log
```

This uses regex to match IP address patterns.

### Find Files Modified by Specific User

```bash title="Find which files mention user 'brad'"
grep -r "brad" /var/log/
```

### Search Compressed Logs

```bash title="Search gzipped log files"
zgrep "error" logfile.gz
```

`zgrep` searches compressed files without extracting them first.

## Combining grep Options

You can combine multiple flags:

```bash title="Case-insensitive, recursive, with line numbers"
grep -rin "TODO" .
```

```bash title="Show context, line numbers, word boundaries"
grep -wnC 2 "port" config.txt
```

```bash title="Count matches, ignore case, in all .log files"
grep -ci "error" *.log
```

## Common Patterns

**Find empty lines:**

```bash
grep "^$" file.txt
```

`^` = start of line, `$` = end of line, so `^$` = empty line.

**Find lines starting with specific text:**

```bash title="Find lines starting with 'ERROR'"
grep "^ERROR" logfile.txt
```

**Find lines ending with specific text:**

```bash title="Find lines ending with semicolon"
grep ";$" script.js
```

**Find lines NOT starting with #:**

```bash title="Show non-comment lines in config file"
grep -v "^#" /etc/ssh/sshd_config
```

Useful for seeing actual settings without comment clutter.

**Find and highlight matches in color:**

```bash title="Colorize matches"
grep --color=auto "error" logfile.txt
```

Matches appear highlighted. Most systems have this aliased by default.

## Regular Expressions (Regex) Basics

`grep` supports powerful pattern matching with regex.

**Dot (.) matches any single character:**

```bash
grep "h.t" words.txt
# Matches: hat, hot, hit, hut, h9t, h@t
```

**Asterisk (*) matches zero or more of previous character:**

```bash
grep "ab*c" file.txt
# Matches: ac, abc, abbc, abbbc, etc.
```

**Plus (+) matches one or more (with -E):**

```bash
grep -E "ab+c" file.txt
# Matches: abc, abbc, abbbc (but NOT ac)
```

**Question mark (?) matches zero or one (with -E):**

```bash
grep -E "colou?r" file.txt
# Matches: color, colour
```

**Character classes:**

```bash
grep "[aeiou]" file.txt      # Lines with any vowel
grep "[0-9]" file.txt         # Lines with any digit
grep "[A-Z]" file.txt         # Lines with uppercase letter
grep "[^0-9]" file.txt        # Lines without digits (^ inside [] means NOT)
```

**Anchors:**

```bash
grep "^start" file.txt        # Lines starting with "start"
grep "end$" file.txt          # Lines ending with "end"
grep "^exact$" file.txt       # Lines containing only "exact"
```

## grep vs Other Tools

**grep** - Search inside files
**find** - Search for files by name/properties
**locate** - Fast file name search using database

```bash
find . -name "*.txt"          # Find files named *.txt
grep "error" *.txt            # Search inside .txt files for "error"
locate config.txt             # Find file named config.txt anywhere
```

Often used together:

```bash title="Find all .log files, then search them for 'error'"
find /var/log -name "*.log" -exec grep "error" {} \;
```

## Performance Tips

**Searching large directories:**

```bash title="Limit to specific file types"
grep -r --include="*.log" "error" /var/log/
```

```bash title="Exclude directories"
grep -r --exclude-dir="node_modules" "TODO" .
```

**Use fixed strings (faster) if you don't need regex:**

```bash title="Fixed string search (no regex)"
grep -F "exact.string.with.dots" file.txt
```

With `-F`, dots are literal, not regex wildcards.

## Common Mistakes

### Forgetting to Quote Patterns with Spaces

```bash
grep error message log.txt
# bash interprets this as: grep "error" "message" "log.txt"
# Tries to search for "error" in files named "message" and "log.txt"
```

**Correct:**

```bash
grep "error message" log.txt
```

### Forgetting -r for Directories

```bash
grep "error" /var/log/
# grep: /var/log/: Is a directory
```

**Correct:**

```bash
grep -r "error" /var/log/
```

### Special Characters Not Escaped

```bash
grep "192.168.1.1" file.txt
# Dots are wildcards in regex, matches 192a168b1c1
```

**Correct (literal dots):**

```bash
grep "192\.168\.1\.1" file.txt
```

Or use `-F`:

```bash
grep -F "192.168.1.1" file.txt
```

### Not Using Quotes for Patterns

```bash
grep $HOME/.bashrc    # Expands $HOME before grep sees it
```

**Correct:**

```bash
grep '$HOME' .bashrc  # Single quotes prevent expansion
```

## Practical Workflows

### Debugging Application Errors

```bash
# Find errors in log
grep -i "error" /var/log/myapp/app.log

# Get context
grep -C 5 "database timeout" /var/log/myapp/app.log

# Count how many times error occurs
grep -c "connection refused" /var/log/myapp/app.log

# Find which log files have this error
grep -rl "memory leak" /var/log/myapp/
```

### Code Review

```bash
# Find all TODO comments
grep -rn "TODO" src/

# Find hardcoded passwords (security audit)
grep -ri "password.*=" .

# Find deprecated function usage
grep -r "old_function_name" src/
```

### System Administration

```bash
# Find failed login attempts
sudo grep "Failed password" /var/log/auth.log

# Find which users are in sudoers
sudo grep -v "^#" /etc/sudoers

# Check listening ports
netstat -tuln | grep "LISTEN"
```

### Configuration File Analysis

```bash
# Show active config (no comments or empty lines)
grep -v "^#" /etc/ssh/sshd_config | grep -v "^$"

# Find specific setting
grep "^Port" /etc/ssh/sshd_config
```

## Key Takeaways

- **`grep "pattern" file`** - Basic search
- **`-i`** - Case-insensitive
- **`-r`** - Recursive (search directories)
- **`-n`** - Show line numbers
- **`-A N` / `-B N` / `-C N`** - Show context (after/before/both)
- **`-v`** - Invert match (show non-matching lines)
- **`-w`** - Match whole words only
- **`-l`** - List filenames with matches
- **`-c`** - Count matches
- **`-E`** - Extended regex
- **Quote your patterns** - Especially with spaces or special characters
- **Use `-F` for literal strings** - Faster, no regex interpretation

`grep` is one of the most-used commands in Linux. Master it, and you'll search faster, debug better, and find information in seconds that would take minutes manually.

Every Linux expert uses `grep` dozens of times a day. It's not optional - it's essential.

Let's keep building skills.
