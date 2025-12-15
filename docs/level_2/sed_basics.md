# Text Transformation: `sed` for Stream Editing

!!! quote "The surgeon's scalpel for text"

## Beyond Find and Replace

You've learned to find files, search inside them, and sort/count data. But what if you need to *change* the text itself? To replace a string, delete lines, or insert new content, `grep` and `awk` aren't enough.

Enter `sed` (Stream Editor) – a powerful, non-interactive text editor that processes text line by line. Think of it as a super-powered find-and-replace tool, capable of intricate transformations. While `awk` is for extracting and analyzing, `sed` is for modifying.

It's the tool you reach for when you need to make consistent changes across many lines or files without manually opening an editor.

## Basic `sed` Syntax

The most common form of `sed` is for **substitution**:

```bash
sed 's/pattern/replacement/flags' file.txt
```

-   `s`: The substitution command.
-   `pattern`: The text or regular expression to search for.
-   `replacement`: The text to replace the `pattern` with.
-   `flags`: Optional modifiers that change `sed`'s behavior (e.g., `g` for global, `i` for case-insensitive).

Let's dive into some common uses.

## Substitution: Changing Text (`s`)

The `s` command is what `sed` is most famous for.

### Simple Replacement

By default, `sed` replaces only the *first* occurrence of `pattern` on each line.

```bash title="Replace 'old' with 'new' (first occurrence per line)"
echo "This old house is very old." | sed 's/old/new/'
```

**Output:**
```
This new house is very old.
```

### Global Replacement (`g` flag)

To replace *all* occurrences of the `pattern` on a line, use the `g` (global) flag.

```bash title="Replace all 'old' with 'new' on each line"
echo "This old house is very old." | sed 's/old/new/g'
```

**Output:**
```
This new house is very new.
```

This is one of the most common flags you'll use.

### Case-Insensitive Replacement (`i` flag)

To ignore case during the search, use the `i` (case-insensitive) flag.

```bash title="Replace 'Error' regardless of case"
echo "ERROR in the matrix. Error code 42." | sed 's/error/warning/gi'
```

**Output:**
```
WARNING in the matrix. WARNING code 42.
```

### Replacing Specific Occurrences (Number flag)

You can specify which occurrence on a line to replace.

```bash title="Replace only the second occurrence"
echo "one two three four" | sed 's/o/X/2'
```

**Output:**
```
one twX three four
```

### Using Different Delimiters

If your pattern or replacement contains `/`, `sed` can get confusing. You can use almost any character as a delimiter.

```bash title="Replace paths using a different delimiter"
echo "/home/user/app" | sed 's#/home/user#/opt/app#'
```

**Output:**
```
/opt/app/app
```

Here, `#` is used as the delimiter instead of `/`. This makes it easier to read when dealing with paths.

### Referencing Matched Patterns (`&`)

The `&` symbol in the replacement string refers to the entire matched `pattern`.

```bash title="Wrap matched word in parentheses"
echo "The quick brown fox" | sed 's/fox/(&)/'
```

**Output:**
```
The quick brown (fox)
```

## Deletion: Removing Lines (`d`)

The `d` command deletes entire lines.

### Delete Lines by Number

```bash title="Delete the second line"
seq 5 | sed '2d'
```

**Output:**
```
1
3
4
5
```

### Delete a Range of Lines

```bash title="Delete lines 2 through 4"
seq 5 | sed '2,4d'
```

**Output:**
```
1
5
```

### Delete Lines Matching a Pattern

```bash title="Delete lines containing 'error'"
cat log.txt | sed '/error/d'
```

**Input (log.txt):**
```
INFO: App started
ERROR: Database connection failed
WARN: Low disk space
INFO: User logged in
```

**Output:**
```
INFO: App started
WARN: Low disk space
INFO: User logged in
```

### Delete Lines NOT Matching a Pattern

To delete lines that *don't* contain a specific pattern, you can combine addressing with the `!` (negation) operator.

```bash title="Keep only lines containing 'ERROR'"
cat log.txt | sed '/ERROR/!d'
```

**Output:**
```
ERROR: Database connection failed
```
This is equivalent to `grep ERROR log.txt` for printing matching lines.

## Printing: Displaying Lines (`p`)

The `p` command prints lines. It's usually combined with the `-n` flag to suppress `sed`'s default behavior of printing every line.

```bash title="Print only the lines matching 'ERROR'"
cat log.txt | sed -n '/ERROR/p'
```

**Output:**
```
ERROR: Database connection failed
```

This is functionally similar to `grep`, but `sed` can do more complex conditional printing.

## In-Place Editing (`-i`)

By default, `sed` prints its output to standard output (your terminal). To modify the file directly, use the `-i` flag.

!!! warning "Use `-i` with caution!"
    `sed -i` makes changes directly to the file. There is **no undo**. Always back up your file or test on a copy first.

```bash title="Replace 'old' with 'new' in file.txt (no backup)"
sed -i 's/old/new/g' file.txt
```

To create a backup before editing:

```bash title="Replace with backup"
sed -i.bak 's/old/new/g' file.txt
```

This will create `file.txt.bak` with the original content, and `file.txt` will contain the changes.

## Addressing: Targeting Lines

You can tell `sed` to apply commands only to specific lines.

### By Line Number

```bash title="Replace 'old' on line 5 only"
sed '5s/old/new/g' file.txt
```

### By Range of Line Numbers

```bash title="Replace 'old' from line 3 to 7"
sed '3,7s/old/new/g' file.txt
```

### By Pattern

```bash title="Replace 'old' only on lines containing 'config'"
sed '/config/s/old/new/g' file.txt
```

### Range by Pattern

```bash title="Replace 'old' starting from line matching 'BEGIN' until line matching 'END'"
sed '/BEGIN/,/END/s/old/new/g' file.txt
```

## Multiple Commands

You can execute multiple `sed` commands in a single pass using `-e` or by separating commands with a semicolon.

```bash title="Replace 'error' and delete lines containing 'debug'"
sed -e 's/error/warning/g' -e '/debug/d' log.txt
# Or:
sed 's/error/warning/g; /debug/d' log.txt
```

## Practical `sed` Examples

### Comment Out Lines

```bash title="Comment out lines containing 'PasswordAuthentication' in sshd_config"
sudo sed -i.bak '/^PasswordAuthentication/s/^/#/' /etc/ssh/sshd_config
```
This prepends `#` to the beginning of any line starting with `PasswordAuthentication`.

### Uncomment Lines

```bash title="Uncomment lines starting with '#Port'"
sudo sed -i 's/^#Port/Port/' /etc/ssh/sshd_config
```

### Delete Blank Lines

```bash title="Delete all empty lines"
sed '/^$/d' file.txt
```
This removes lines that contain only a newline character.

### Delete Leading/Trailing Whitespace

```bash title="Remove leading whitespace"
sed 's/^[ \t]*//' file.txt
```
```bash title="Remove trailing whitespace"
sed 's/[ \t]*$//' file.txt
```
```bash title="Remove both"
sed 's/^[ \t]*//;s/[ \t]*$//' file.txt
```

### Change Date Format (Simple Example)

Assuming dates like `YYYY-MM-DD` and converting to `MM/DD/YYYY`.

```bash title="Convert date format"
echo "2024-12-14" | sed 's/\([0-9]\{4\}\)-\([0-9]\{2\}\)-\([0-9]\{2\}\)/\2\/\3\/\1/'
```
This introduces capturing groups `\(...)` and backreferences `\1`, `\2`, `\3`.

## Common Mistakes

### Not Using `g` for Global Replacement

If you only want to replace the first occurrence on each line, great. But often, you want all of them.

```bash
echo "foo foo bar" | sed 's/foo/baz/'  # Output: baz foo bar
echo "foo foo bar" | sed 's/foo/baz/g' # Output: baz baz bar
```

### Forgetting to Quote the `sed` Expression

If your `sed` command contains spaces or special characters, the shell might interpret them before `sed` sees them. Always quote the expression.

```bash
# Bad (shell might expand *)
sed s/old/*/g file.txt

# Good
sed 's/old/*/g' file.txt
```

### Using `/` as a Delimiter in Paths

If your pattern or replacement contains `/`, choose a different delimiter.

```bash
# Bad
sed 's/\/var\/log\/\/home\/log/g' file.txt

# Good
sed 's#/var/log#/home/log#g' file.txt
```

### Not Backing Up with `-i`

Accidental changes can be permanent. Always use `-i.bak` or work on a copy.

### Forgetting `g` when using `-i`

`sed -i 's/pattern/replacement'` only replaces the first match on each line. If you mean *all* matches, add `g`: `sed -i 's/pattern/replacement/g'`.

## Quick Reference: `sed` Commands

| Command | Description | Example |
|:---|:---|:---|
| `s/pattern/replacement/flags` | Substitute `pattern` with `replacement`. | `sed 's/old/new/g'` |
| `d` | Delete lines. | `sed '/error/d'` |
| `p` | Print lines (use with `-n`). | `sed -n '5p'` |
| `-i[suffix]` | Edit file in place, optionally creating backup. | `sed -i.bak 's/foo/bar/g' file.txt` |
| `-e command` | Execute multiple commands. | `sed -e 's/a/b/' -e 's/c/d/'` |
| `/pattern/cmd` | Apply command to lines matching pattern. | `sed '/ERROR/d'` |
| `N,M cmd` | Apply command to lines N through M. | `sed '5,10d'` |
| `/P1/,/P2/cmd` | Apply command to lines from P1 to P2. | `sed '/BEGIN/,/END/d'` |

## Practice Exercises

**Exercise 1: Simple Replacement**
Change all instances of "old_host" to "new_host" in `config.txt`.
```bash
echo "SERVER_HOST=old_host\nDB_HOST=old_host" > config.txt
sed 's/old_host/new_host/g' config.txt
cat config.txt
```

**Exercise 2: Delete Log Entries**
Delete all lines containing "debug" from `application.log`.
```bash
echo "INFO\nDEBUGGING\nERROR\nDEBUG" > application.log
sed '/debug/Id' application.log # Use I for case-insensitive deletion
cat application.log
```

**Exercise 3: Comment and Uncomment**
Comment out the line starting with "Port" in a simulated `sshd_config` file. Then uncomment it.
```bash
echo "Port 22\n#ListenAddress 0.0.0.0" > sshd_config.tmp
sed 's/^Port/#Port/' sshd_config.tmp # Comment out
sed 's/^#Port/Port/' sshd_config.tmp # Uncomment
cat sshd_config.tmp
```

**Exercise 4: Extract Specific Data**
From a log file, extract only the date (first field) if the line contains "WARNING".
```bash
echo "2024-12-14 WARNING: Disk full\n2024-12-13 INFO: Service started" > log.txt
sed -n '/WARNING/s/^\([^ ]*\).*$/\1/p' log.txt # Prints only the date from WARNING lines
```
*(This is a bit more advanced regex, combining pattern matching and capturing groups.)*

## Key Takeaways

-   **`sed` is for text transformation** (changing, deleting, inserting).
-   **`s/pattern/replacement/flags`** is the main substitution command.
-   Use `g` for global replacement, `i` for case-insensitive.
-   **`d`** deletes lines.
-   **`p`** prints lines (use with `-n`).
-   **`-i`** allows in-place editing (use with caution and backups).
-   You can **address lines** by number, range, or pattern.
-   **Regular expressions** are key to its power.

`sed` is a fundamental tool for system administrators and developers who need to automate text processing. It might seem intimidating at first, but mastering its basic substitution and deletion capabilities will save you immense time when dealing with configuration files, scripts, and logs.

Consider it an indispensable part of your Linux toolkit.

Let's keep building.
