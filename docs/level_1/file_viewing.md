# File Viewing Quick Reference

!!! quote "Four ways to peek inside files"

## Why Multiple Commands?

You know how to navigate and manage files. Now you need to actually *look inside them* - read logs, check configuration files, review code, debug errors.

**Linux gives you multiple tools for viewing files because different situations need different approaches:**

- **Need the whole file?** Use `cat`
- **File is too long for one screen?** Use `less`
- **Just want the beginning?** Use `head`
- **Just want the end (like recent log entries)?** Use `tail`

Each command has a specific purpose. Learning when to use which makes you efficient.

## The Quick Dump: `cat`

`cat` stands for "concatenate" but is mostly used to display file contents.

```bash title="Display entire file"
cat myfile.txt
```

Contents scroll by and that's it - no paging, no scrolling back.

**Perfect for:**

- Short files (a few lines)
- Quick checks ("what's in this file?")
- Piping output to other commands

**Not good for:**

- Long files (output scrolls off screen)
- Binary files (shows garbage)

### Common `cat` Uses

**View a config file:**

```bash
cat /etc/hosts
```

**View multiple files:**

```bash
cat file1.txt file2.txt
```

Shows file1, then file2, concatenated (hence the name).

**Number lines:**

```bash title="Show line numbers"
cat -n script.sh
```

**Output:**
```
     1  #!/bin/bash
     2  echo "Hello"
     3  exit 0
```

**Show non-printing characters:**

```bash title="Show tabs and end-of-line markers"
cat -A myfile.txt
```

Tabs show as `^I`, line endings as `$`. Useful for debugging whitespace issues.

### When NOT to Use `cat`

```bash
cat /var/log/syslog  # 10,000 lines fly by - useless
```

For long files, use `less` instead.

```bash
cat image.jpg  # Displays binary garbage, might mess up your terminal
```

For binary files, don't use `cat`.

## The Pager: `less`

`less` is an interactive file viewer - like a book you can flip through.

```bash title="View a file with less"
less /var/log/syslog
```

**Navigation:**

- **Space** or **Page Down** - Next page
- **b** or **Page Up** - Previous page
- **Down arrow** - Down one line
- **Up arrow** - Up one line
- **g** - Go to beginning of file
- **G** - Go to end of file
- **/**pattern - Search forward for "pattern"
- **?**pattern - Search backward for "pattern"
- **n** - Next search result
- **N** - Previous search result
- **q** - Quit

### Searching in `less`

```bash
less /var/log/syslog
```

Once inside less:

```
/error<Enter>     # Search for "error"
n                 # Next match
n                 # Next match
q                 # Quit
```

**Case-insensitive search:**

```
/ERROR\c<Enter>   # \c makes it case-insensitive
```

Or start less with `-i` flag:

```bash
less -i logfile.txt
```

### Useful `less` Options

**Follow file in real-time (like `tail -f`):**

```bash title="Watch log file update live"
less +F /var/log/syslog
```

Press **Ctrl+C** to stop following, **F** to resume.

**Show line numbers:**

```bash
less -N myfile.txt
```

**Don't wrap long lines:**

```bash
less -S widedata.csv
```

Use left/right arrows to scroll horizontally.

### `less` vs `more`

`more` is an older, simpler pager. `less` has more features:

- Backward navigation (more can't go back)
- Search (more has limited search)
- Better performance on large files

**"Less is more"** is the joke - `less` does more than `more`.

Use `less`. Always.

## The Beginning: `head`

`head` shows the first 10 lines of a file.

```bash title="Show first 10 lines"
head /var/log/syslog
```

**Specify number of lines:**

```bash title="Show first 20 lines"
head -n 20 /var/log/syslog
```

Or shorthand:

```bash
head -20 /var/log/syslog
```

**View first lines of multiple files:**

```bash
head file1.txt file2.txt file3.txt
```

Output shows filename headers:

```
==> file1.txt <==
First line of file1
Second line of file1
...

==> file2.txt <==
First line of file2
...
```

**Show first N bytes instead of lines:**

```bash title="Show first 100 bytes"
head -c 100 large-file.bin
```

### Common `head` Uses

**Quick check of file contents:**

```bash
head README.md     # See what this file is about
```

**Check CSV structure:**

```bash
head data.csv      # See column headers
```

**Sample log files:**

```bash
head /var/log/apache2/access.log
```

## The End: `tail`

`tail` shows the last 10 lines of a file.

```bash title="Show last 10 lines"
tail /var/log/syslog
```

**This is where logs are most useful** - recent events are at the end.

**Specify number of lines:**

```bash title="Show last 50 lines"
tail -n 50 /var/log/syslog
```

Or:

```bash
tail -50 /var/log/syslog
```

**Follow file in real-time:**

```bash title="Watch file update live"
tail -f /var/log/syslog
```

New lines appear as they're written to the file. **This is the most common use of `tail`.**

Press **Ctrl+C** to stop.

**Follow multiple files:**

```bash
tail -f /var/log/syslog /var/log/auth.log
```

Shows updates from both files with filename headers.

**Start from specific line:**

```bash title="Show from line 100 to end"
tail -n +100 large-file.txt
```

The `+` means "starting at line 100."

### Common `tail` Uses

**Watch logs in real-time:**

```bash
tail -f /var/log/apache2/error.log
```

Deploy code, then watch for errors. Essential for debugging.

**Check recent system activity:**

```bash
tail /var/log/syslog
```

**View end of large files:**

```bash
tail -100 huge-logfile.log | less
```

Get last 100 lines, then page through them.

**Monitor multiple logs:**

```bash
tail -f /var/log/{syslog,auth.log,kern.log}
```

Watches all three files simultaneously.

## Combining Commands

The real power comes from combining these commands.

**See first and last 5 lines:**

```bash
head -5 file.txt && echo "..." && tail -5 file.txt
```

**Count lines in a file:**

```bash
cat file.txt | wc -l
```

Better:

```bash
wc -l file.txt
```

`wc -l` counts lines directly - no need for `cat`.

**View specific line range:**

```bash title="Show lines 50-60"
head -60 file.txt | tail -10
```

Gets first 60 lines, then shows last 10 of those (lines 51-60).

Or use `sed`:

```bash
sed -n '50,60p' file.txt
```

**Search and view context:**

```bash
grep -n "error" logfile.txt | head
```

Find lines with "error", show first 10 matches with line numbers.

## Quick Reference Table

| Command | What It Shows | Use When |
|---------|---------------|----------|
| `cat file` | Entire file | File is short, or piping to another command |
| `less file` | Pageable view | File is long, need to navigate |
| `head file` | First 10 lines | Want to see beginning |
| `head -n 20 file` | First 20 lines | Need more context from start |
| `tail file` | Last 10 lines | Want recent log entries |
| `tail -n 50 file` | Last 50 lines | Need more log context |
| `tail -f file` | Live updates | Watching active log file |

## Practical Scenarios

### Scenario 1: Debugging a Web Server

```bash
# Check if Apache is running
tail /var/log/apache2/error.log

# Watch for new errors while you test
tail -f /var/log/apache2/error.log

# In another terminal, trigger the error
# Watch it appear in the log

# Stop watching
Ctrl+C
```

### Scenario 2: Examining a Config File

```bash
# Quick check
cat /etc/ssh/sshd_config

# File is long, page through it
less /etc/ssh/sshd_config

# Search for specific setting
# (press / then type "PermitRootLogin")

# Found it, quit
q
```

### Scenario 3: Analyzing CSV Data

```bash
# Check column headers
head -1 data.csv

# See first few rows
head data.csv

# Check last few rows for any issues
tail data.csv

# Count total rows
wc -l data.csv
```

### Scenario 4: Monitoring System Logs

```bash
# Check recent system activity
tail -50 /var/log/syslog | less

# Watch for new events
sudo tail -f /var/log/syslog

# Watch both system and authentication logs
sudo tail -f /var/log/{syslog,auth.log}
```

## Advanced Tips

**View compressed files:**

```bash
zcat logfile.gz           # cat for gzip files
zless logfile.gz          # less for gzip files
bzcat logfile.bz2         # cat for bzip2 files
```

**View file without line wrapping:**

```bash
less -S wide-file.log
```

Use arrow keys to scroll horizontally.

**Show filename headers for multiple files:**

```bash
tail -n 5 *.log
```

Each file's last 5 lines with headers.

**Follow the latest file in a directory:**

```bash
tail -f $(ls -t /var/log/app/*.log | head -1)
```

Finds most recently modified log, follows it.

**Highlight search terms:**

```bash
less file.txt
# Press / to search
# Matches are highlighted
```

Or pipe through `grep` with color:

```bash
grep --color=always "pattern" file.txt | less -R
```

## Common Mistakes

### Using `cat` for Long Files

```bash
cat /var/log/syslog   # 10,000 lines scroll by
```

**Better:**

```bash
less /var/log/syslog
```

### Forgetting `-f` with `tail`

```bash
tail /var/log/syslog   # Shows last 10 lines, exits
```

**For monitoring:**

```bash
tail -f /var/log/syslog   # Keeps watching
```

### Not Quitting `less`

Press **q** to quit. Don't close the terminal window.

### Piping `cat` Unnecessarily

```bash
cat file.txt | grep "pattern"   # Works but wasteful
```

**Better:**

```bash
grep "pattern" file.txt         # Grep can read files directly
```

This is called "useless use of cat" (UUOC).

## Practice Exercises

**Exercise 1: File viewing basics**

```bash
cd /var/log
ls
head syslog           # First 10 lines
tail syslog           # Last 10 lines
less syslog           # Page through, press q to quit
```

**Exercise 2: Search in less**

```bash
less /etc/services
/http<Enter>          # Search for "http"
n                     # Next match
q                     # Quit
```

**Exercise 3: Follow a log**

```bash
# Terminal 1:
tail -f /var/log/syslog

# Terminal 2:
logger "This is a test message"

# Watch it appear in Terminal 1
# Press Ctrl+C in Terminal 1 to stop
```

**Exercise 4: View multiple files**

```bash
head /etc/os-release /etc/lsb-release
```

## Key Takeaways

- **`cat`** - Quick dump of entire file; good for short files
- **`less`** - Interactive paging; use for long files
- **`head`** - First N lines (default 10)
- **`tail`** - Last N lines (default 10)
- **`tail -f`** - Follow file in real-time (essential for logs)
- **`less` navigation** - Space/b for pages, /pattern to search, q to quit
- **Don't `cat` long files** - use `less` instead
- **Avoid useless use of `cat`** - many commands read files directly

Viewing files is something you'll do constantly - checking configs, reading logs, debugging code, analyzing data. These four commands handle 95% of those tasks.

**Master `less` especially** - it's your go-to for exploring unfamiliar files. Get comfortable with search (`/pattern`), navigation (space/b), and quitting (q).

The command line isn't just powerful for creating and moving files - it's powerful for reading and understanding them too.

Let's keep building.
