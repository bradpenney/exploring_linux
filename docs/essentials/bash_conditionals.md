---
date: "2026-06-03 21:58"
title: "Bash Conditionals — if/elif and Test Operators"
description: "Write Bash conditionals that work reliably. Covers if/elif/else, the [[ ]] operator, common file and string tests, and patterns that avoid subtle bugs."
---

# Conditionals

!!! tip "Part of Essentials — Bash Scripting"
    Fourth in the Essentials Bash series. Assumes you understand [Arguments and Exit Codes](bash_arguments.md). Next up: [Loops](bash_loops.md).

Every real script makes decisions: does this file exist? Did that command succeed? Is this variable set? Bash conditionals are the logic layer that turns a list of commands into a real program.

---

## Where You've Seen This

The `if/elif/else` structure is the same as every other scripting language. The one mental shift: Bash conditions are exit codes, not booleans. A command that exits 0 is "true"; non-zero is "false." Once that clicks, the rest follows.

---

## if / elif / else

The syntax is straightforward. What matters more is the pattern: in real scripts, conditionals are mostly guard clauses — check what could go wrong at the top and exit immediately if it does. The rest of the script then runs with confidence that its preconditions are met.

``` bash title="Basic if Structure" linenums="1"
if [[ condition ]]; then
    # runs if condition is true
elif [[ other_condition ]]; then
    # runs if first condition was false and this is true
else
    # runs if no condition was true
fi
```

`fi` closes every `if`. The `then` keyword requires either a `;` before it on the same line, or a newline — both are valid, the single-line form is more common in scripts.

---

## The `[[ ]]` Test Operator

`[[ ]]` is Bash's built-in test expression. It evaluates a condition and exits 0 (true) or 1 (false) — which means it works directly inside `if`, `while`, and `&&`/`||` chains.

=== "File Existence"

    Before operating on a file, confirm it exists and is what you expect. The `-f` and `-d` tests are the most common in production scripts:

    ``` bash title="File Existence Tests" linenums="1"
    [[ -e "/path/to/thing" ]]    # (1)!
    [[ -f "/path/to/file" ]]     # (2)!
    [[ -d "/path/to/dir" ]]      # (3)!
    [[ -L "/path/to/link" ]]     # (4)!
    [[ -s "/path/to/file" ]]     # (5)!
    ```

    1. Exists — file or directory.
    2. Exists and is a regular file.
    3. Exists and is a directory.
    4. Exists and is a symlink.
    5. Exists and is non-empty (size > 0).

=== "Permissions"

    Validate your script has the access it needs before attempting an operation. A permission failure mid-script is harder to debug than a clear error at the start — see [File Permissions](file_permissions.md):

    ``` bash title="Permission Tests" linenums="1"
    [[ -r "/path/to/file" ]]     # (1)!
    [[ -w "/path/to/file" ]]     # (2)!
    [[ -x "/path/to/file" ]]     # (3)!
    ```

    1. Readable by the current user.
    2. Writable by the current user.
    3. Executable by the current user.

=== "Strings"

    Use string tests to validate variables before using them. An empty variable used in a destructive command is the most common source of production incidents:

    ``` bash title="String Tests" linenums="1"
    [[ -z "${VAR}" ]]              # (1)!
    [[ -n "${VAR}" ]]              # (2)!
    [[ "${A}" == "${B}" ]]         # (3)!
    [[ "${A}" != "${B}" ]]         # (4)!
    [[ "${STR}" == *"substr"* ]]   # (5)!
    [[ "${STR}" =~ ^[0-9]+$ ]]    # (6)!
    ```

    1. True if `VAR` is empty or unset.
    2. True if `VAR` is non-empty.
    3. String equality.
    4. String inequality.
    5. Contains substring — `==` with a glob pattern.
    6. Matches regex — the pattern is unquoted on the right-hand side.

=== "Numeric"

    Use `-eq`, `-lt`, `-gt` for numeric comparisons. `==` does string comparison — `[[ 10 == 9 ]]` is false but `[[ 10 > 9 ]]` does a string sort, not a numeric one:

    ``` bash title="Numeric Tests" linenums="1"
    [[ $a -eq $b ]]    # (1)!
    [[ $a -ne $b ]]    # (2)!
    [[ $a -lt $b ]]    # (3)!
    [[ $a -gt $b ]]    # (4)!
    [[ $a -le $b ]]    # (5)!
    [[ $a -ge $b ]]    # (6)!
    ```

    1. Equal.
    2. Not equal.
    3. Less than.
    4. Greater than.
    5. Less than or equal.
    6. Greater than or equal.

### Combining Conditions

Use `&&` and `||` inside `[[ ]]` to express complex guards in a single test rather than nesting multiple `if` blocks:

``` bash title="Logical Operators" linenums="1"
if [[ -f "${config}" && -r "${config}" ]]; then   # (1)!
    echo "Config is readable"
fi

if [[ "${env}" == "production" || "${env}" == "staging" ]]; then  # (2)!
    echo "Deploying to a live environment"
fi

if [[ ! -d "${output_dir}" ]]; then   # (3)!
    mkdir -p "${output_dir}"
fi
```

1. Both conditions must be true — file exists AND is readable.
2. Either condition satisfies — `production` OR `staging`.
3. `!` inverts the test — runs the body when the directory does NOT exist.

---

## `[[ ]]` vs `[ ]`

You'll see both in existing scripts:

| Feature | `[[ ]]` | `[ ]` |
|---------|---------|-------|
| Word splitting on variables | ❌ No — safer | ✅ Yes — requires careful quoting |
| Pattern matching with `==` | ✅ Glob patterns | ❌ No |
| Regex with `=~` | ✅ Yes | ❌ No |
| `&&` and `\|\|` inside the test | ✅ Yes | ❌ No |
| Portability | Bash only | POSIX sh compatible |

Use `[[ ]]` in Bash scripts. Use `[ ]` only when you need POSIX sh portability (scripts starting with `#!/bin/sh`).

---

## Testing Command Success

This is where Bash conditionals become uniquely powerful. Because `if` evaluates exit codes, *any command* works as a condition — not just `[[ ]]` tests. You can branch directly on whether a command succeeded or failed, without capturing its output or checking `$?`:

``` bash title="Commands as Conditions" linenums="1"
if grep -q "error" /var/log/app.log; then   # (1)!
    echo "Errors found in log"
fi

if ! systemctl is-active --quiet nginx; then  # (2)!
    echo "nginx is not running — starting it"
    systemctl start nginx
fi

if ! command -v jq &>/dev/null; then   # (3)!
    echo "Error: jq is required but not installed" >&2
    exit 1
fi
```

1. `grep -q` runs silently — the exit code is the condition. 0 if the pattern was found, 1 if not.
2. `!` inverts the exit code — this block runs when `nginx` is NOT active.
3. `command -v` is the portable way to check whether a program exists in PATH.

---

## Real-World Patterns

=== "File System Checks"

    Any script that reads a config file or writes to a directory should validate its paths before doing any work. Fail with a clear message rather than letting the script crash mid-way:

    ``` bash title="Validate Before Running" linenums="1"
    #!/usr/bin/env bash

    config_file="${1:-/etc/myapp/config.yml}"

    if [[ ! -f "${config_file}" ]]; then       # (1)!
        echo "Error: config file not found: ${config_file}" >&2
        exit 1
    fi

    if [[ ! -r "${config_file}" ]]; then       # (2)!
        echo "Error: config file not readable: ${config_file}" >&2
        exit 1
    fi

    echo "Config OK: ${config_file}"
    ```

    1. Guard against a missing file before trying to read it.
    2. Guard against a permission problem separately — the error message tells the user exactly what's wrong.

=== "String Comparisons"

    Validate string arguments as soon as you receive them — before any logic that depends on their value. An invalid value caught early gives a clear error; one caught late produces confusing behaviour:

    ``` bash title="Validate String Arguments" linenums="1"
    #!/usr/bin/env bash

    env="$1"

    if [[ -z "${env}" ]]; then    # (1)!
        echo "Error: environment argument required" >&2
        exit 1
    fi

    if [[ "${env}" != "production" && "${env}" != "staging" && "${env}" != "dev" ]]; then  # (2)!
        echo "Error: invalid environment '${env}'. Must be: production, staging, dev" >&2
        exit 1
    fi

    echo "Target environment: ${env}"
    ```

    1. Check for empty before checking the value — an empty variable would pass most value checks silently.
    2. Allowlist validation — reject anything not explicitly permitted.

=== "Preflight Checks"

    Consolidate everything that must be true before a script's main work begins. A preflight block at the top means the script either starts with confidence or fails immediately with a clear reason:

    ``` bash title="Preflight Check" linenums="1"
    #!/usr/bin/env bash

    if [[ -z "${DB_HOST}" || -z "${API_KEY}" ]]; then   # (1)!
        echo "Error: DB_HOST and API_KEY must be set" >&2
        exit 1
    fi

    if ! command -v psql &>/dev/null; then              # (2)!
        echo "Error: psql is not installed" >&2
        exit 1
    fi

    if ! psql -h "${DB_HOST}" -c "SELECT 1" &>/dev/null; then  # (3)!
        echo "Error: cannot connect to database at ${DB_HOST}" >&2
        exit 1
    fi

    echo "All checks passed — starting deployment"
    ```

    1. Check required environment variables first — cheapest check, most common failure.
    2. Check required tools before trying to use them.
    3. Verify the actual connection — the most expensive check, so it comes last.

---

## Practice Exercises

??? question "Exercise 1: File Validation Script"
    Write a script that accepts a file path as its argument and:

    1. Exits with code 1 if no argument is provided
    2. Exits with code 2 if the path exists but is a directory, not a file
    3. Exits with code 3 if the file doesn't exist
    4. Prints `"File OK: {path}"` and exits with code 0 if the file exists and is readable

    ??? tip "Solution"
        ``` bash title="validate-file.sh" linenums="1"
        #!/usr/bin/env bash

        if [[ $# -lt 1 ]]; then
            echo "Usage: $0 <file-path>" >&2
            exit 1
        fi

        path="$1"

        if [[ -d "${path}" ]]; then
            echo "Error: ${path} is a directory, not a file" >&2
            exit 2
        fi

        if [[ ! -f "${path}" ]]; then
            echo "Error: ${path} does not exist" >&2
            exit 3
        fi

        echo "File OK: ${path}"
        exit 0
        ```

??? question "Exercise 2: OS Family Detector"
    Write a script that detects the Linux distribution family:

    1. If `/etc/debian_version` exists, print "Debian-based system"
    2. If `/etc/redhat-release` exists, print "Red Hat-based system"
    3. If `/etc/arch-release` exists, print "Arch Linux"
    4. Otherwise, print "Unknown distribution"

    ??? tip "Solution"
        ``` bash title="detect-os.sh" linenums="1"
        #!/usr/bin/env bash

        if [[ -f "/etc/debian_version" ]]; then
            echo "Debian-based system"
        elif [[ -f "/etc/redhat-release" ]]; then
            echo "Red Hat-based system"
        elif [[ -f "/etc/arch-release" ]]; then
            echo "Arch Linux"
        else
            echo "Unknown distribution"
        fi
        ```

---

## Quick Recap

- Guard-first: check what can go wrong at the top, exit early, then run the main logic with confidence
- `if [[ condition ]]; then ... elif ... else ... fi` — `fi` closes every `if`
- Use `[[ ]]` not `[ ]` in Bash scripts — no word splitting, supports globs and regex
- File tests: `-f` (regular file), `-d` (directory), `-e` (exists), `-r/-w/-x` (permissions), `-s` (non-empty)
- String tests: `-z` (empty), `-n` (non-empty), `==`, `!=`, `=~` (regex), `==` with `*` (glob)
- Numeric tests: `-eq`, `-ne`, `-lt`, `-gt`, `-le`, `-ge`
- Any command works as a condition — its exit code is the test
- `&&` and `||` combine conditions; `!` inverts them

---

## Further Reading

### Command References

- `man bash` — the "Conditional Expressions" section lists every test operator
- `help test` — Bash built-in help for `[ ]` expressions

### Deep Dives

- [Bash FAQ: test, \[, and \[\[](https://mywiki.wooledge.org/BashFAQ/031) — Wooledge wiki's complete comparison of all three test constructs

### Official Documentation

- [GNU Bash Manual: Conditional Constructs](https://www.gnu.org/software/bash/manual/bash.html#Conditional-Constructs)
- [GNU Bash Manual: Bash Conditional Expressions](https://www.gnu.org/software/bash/manual/bash.html#Bash-Conditional-Expressions)

### Exploring Python

- [Is It Still Up?](https://python.bradpenney.io/day_one/health_check/) — When `if [[ ]]` checks grow into full health-check loops with retries and structured failure reporting: the Python approach to service monitoring

---

## What's Next?

Head to **[Loops](bash_loops.md)** — `for` and `while`, iterating over files and command output, and the patterns that make repetition reliable.
