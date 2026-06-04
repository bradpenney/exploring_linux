---
title: "Bash Variables and Quoting — Avoiding Common Pitfalls"
description: "Master Bash variables and quoting rules. Learn when to use double vs single quotes, command substitution, and how quoting bugs silently break your scripts."
---

# Variables and Quoting

!!! tip "Part of Essentials — Bash Scripting"
    Second in the Essentials Bash series. Assumes you've read [Your First Bash Script](bash_first_script.md) and are comfortable with basic script structure. Next up: [Arguments and Exit Codes](bash_arguments.md).

`rm -rf $target/` works fine in testing. Set `$target` to an empty string in production — even accidentally — and it becomes `rm -rf /`. That's an unquoted variable bug. Quoting is how you prevent a script from doing something catastrophic with unexpected input. This article covers the rules once, so they stick.

---

## Where You've Seen This

If you've set environment variables in Windows (System Properties → Environment Variables) or seen `%APP_PATH%` in a batch file, the concept is identical — a named value the shell expands on demand. Bash uses `$VAR` instead of `%VAR%`, and `name="value"` with no spaces around `=`; that space is the first thing most people get wrong.

---

## Declaring Variables

Variables let you name a value once and use it everywhere in a script. Change it in one place and every reference picks up the change — no hunting for hardcoded paths or repeated hostnames.

``` bash title="Variable Assignment" linenums="1"
app_name="myapp"          # (1)!
server_count=5            # (2)!
log_path="/var/log/app"   # (3)!
```

1. Strings go in double quotes.
2. Integers don't need quotes.
3. Paths in double quotes — safe against word splitting if the value ever changes.

**The one rule that trips everyone up:** no spaces around `=`.

``` bash title="What NOT to Do" linenums="1"
app_name = "myapp"    # (1)!
```

1. Bash treats `app_name` as a command, `=` as its first argument, and `"myapp"` as its second. Result: `app_name: command not found`.

### Expanding Variables

To use a variable's value, prefix it with `$`. Braces are optional but recommended in scripts — they make boundaries explicit and prevent ambiguity:

``` bash title="Variable Expansion" linenums="1"
echo $app_name               # (1)!
echo ${app_name}             # (2)!
echo "App: ${app_name}!"     # (3)!
echo 'App: ${app_name}!'     # (4)!
```

1. Simple expansion — works, but `$app_namesuffix` would try to expand `app_namesuffix`, not `app_name`.
2. Braces make the boundary explicit — `${app_name}suffix` expands correctly.
3. Double quotes: the variable expands normally.
4. Single quotes: everything is literal — prints `${app_name}`, not the value.

---

## Quoting Rules

This table is worth memorising:

| Context | Variable expands? | Word splitting? |
|---------|------------------|-----------------|
| Unquoted (`$VAR`) | ✅ Yes | ✅ Yes — splits on whitespace |
| Double quotes (`"$VAR"`) | ✅ Yes | ❌ No |
| Single quotes (`'$VAR'`) | ❌ No | ❌ No |

**The default:** use double quotes around variables in scripts. Single quotes are for literal strings where you explicitly don't want expansion.

### Why Unquoted Variables Break

Word splitting means Bash splits the variable's value on whitespace and treats each piece as a separate argument. An empty variable expands to nothing — silently dropping the argument entirely:

``` bash title="Word Splitting" linenums="1"
log_message="connection refused"

logger $log_message      # (1)!
logger "${log_message}"  # (2)!
```

1. Passes two arguments: `connection` as the log message, `refused` as a syslog tag. Wrong.
2. Passes one argument: `connection refused` as the message. Correct.

---

## Where Variables Come From

In any running script, variables arrive from three sources. Knowing the source is the fastest way to debug a variable that isn't what you expect.

**1. Your script** — Variables you declare yourself. Use these for any value you compute, configure, or reference more than once:

``` bash title="Script Variables" linenums="1"
deploy_env="production"
max_retries=3
log_dir="/var/log/${app_name}"  # (1)!
```

1. Variables can reference other variables. `${app_name}` expands at the time this line runs.

**2. The environment** — Variables inherited from whoever ran the script — the shell, a service manager, or a calling process. `$HOME`, `$USER`, and `$PATH` are always present. Custom variables (API keys, config paths) arrive this way from calling scripts or automation systems:

``` bash title="Environment Variables" linenums="1"
echo "${HOME}"               # (1)!
echo "${USER}"               # (2)!
echo "${PATH}"               # (3)!

export DB_HOST="db-prod-01"  # (4)!
```

1. Your home directory — set by the shell at login.
2. The current user's login name.
3. Colon-separated list of directories Bash searches for commands — see [Filesystem Hierarchy](filesystem_hierarchy.md).
4. `export` makes a variable visible to any child process this script starts. Without it, child processes don't see the variable.

**3. Bash itself** — Set automatically by Bash, not by you. Read them; don't assign to them:

``` bash title="Special Variables" linenums="1"
echo "Script: $0"   # (1)!
echo "PID:    $$"   # (2)!
echo "Exit:   $?"   # (3)!
```

1. The script's name as called — useful in usage messages and error output.
2. The current script's process ID.
3. Exit code of the last command: 0 = success, non-zero = failure.

These are covered in full in [Arguments and Exit Codes](bash_arguments.md).

You can also mark any of your own variables `readonly` to prevent reassignment — useful for values that must not change after initialisation:

``` bash title="Readonly Variables" linenums="1"
readonly MAX_CONNECTIONS=100
readonly CONFIG_DIR="/etc/myapp"
```

---

## Command Substitution

Some values only exist at runtime — today's date, current disk usage, a server's hostname. Command substitution captures a command's output as a string you can assign to a variable or embed inline:

``` bash title="Command Substitution" linenums="1"
current_date=$(date +%Y-%m-%d)                        # (1)!
free_disk=$(df -h / | awk 'NR==2 {print $4}')        # (2)!
host_count=$(grep -c "^[^#]" /etc/hosts)             # (3)!
```

1. Captures today's date in `YYYY-MM-DD` format.
2. The entire pipeline runs in a subshell; only the final output is captured.
3. Counts non-comment lines in `/etc/hosts` — a pipeline of arbitrary complexity works here.

Always quote the result — command output can contain spaces or be empty:

``` bash title="Quote Command Substitution Output" linenums="1"
output=$(some_command)

process_entry $output     # (1)!
process_entry "${output}" # (2)!
```

1. If `output` contains spaces it splits into multiple arguments; if empty the argument disappears entirely.
2. Always quoted — one argument regardless of what the command returns.

The backtick syntax (`` `command` ``) is equivalent but harder to read and can't be nested cleanly. Use `$(...)`.

---

## Default Values

Scripts run in different environments. On your workstation `LOG_DIR` is set. On a colleague's machine or in a CI run it isn't. Default value operators handle both cases without `if/else` logic:

``` bash title="Default Value Operators" linenums="1"
log_dir="${LOG_DIR:-/var/log/myapp}"  # (1)!
log_dir="${LOG_DIR-/var/log/myapp}"   # (2)!
: "${DEPLOY_ENV:=production}"         # (3)!
: "${API_KEY:?API_KEY must be set}"   # (4)!
```

1. Use the default if `LOG_DIR` is unset **or empty**.
2. Use the default only if `LOG_DIR` is unset — an empty string is kept as-is.
3. Set `DEPLOY_ENV` to `production` if unset or empty, and keep it set. The `:` command discards the value; the side effect is the assignment.
4. Exit with an error if `API_KEY` is unset or empty. Use this at the top of scripts that require specific variables.

=== "Configuration Pattern"

    ``` bash title="Script with Configurable Defaults" linenums="1"
    #!/usr/bin/env bash

    LOG_DIR="${LOG_DIR:-/var/log/myapp}"
    MAX_RETRIES="${MAX_RETRIES:-3}"
    TIMEOUT="${TIMEOUT:-30}"

    echo "Logging to: ${LOG_DIR}"
    echo "Max retries: ${MAX_RETRIES}"
    echo "Timeout: ${TIMEOUT}s"
    ```

    Run as-is for defaults, or override at call time: `LOG_DIR=/tmp/test ./deploy.sh`

=== "Require a Variable"

    ``` bash title="Validate Required Variables" linenums="1"
    #!/usr/bin/env bash

    : "${API_KEY:?Error: API_KEY must be set. Export it before running this script.}"
    : "${DB_HOST:?Error: DB_HOST must be set.}"

    echo "Connecting to ${DB_HOST}..."
    ```

    Put these at the top of any script that depends on external variables — it fails immediately with a clear message rather than silently using empty values deep in the script.

---

## Practice Exercises

??? question "Exercise 1: Diagnose the Quoting Bug"
    This script has a dangerous quoting bug. Identify it and fix it:

    ``` bash title="Buggy Script" linenums="1"
    #!/usr/bin/env bash
    target_dir="$1"
    rm -rf $target_dir/cache
    ```

    ??? tip "Solution"
        `$target_dir` is unquoted. If `$1` is empty — no argument was passed — `$target_dir` expands to nothing and the command becomes `rm -rf /cache`. Quote it, and validate the argument is set before using it:

        ``` bash title="Fixed Script" linenums="1"
        #!/usr/bin/env bash
        target_dir="${1:?Error: target directory required}"
        rm -rf "${target_dir}/cache"
        ```

        The `:?` operator exits with an error if the variable is unset or empty.

??? question "Exercise 2: Build a Deployment Info Script"
    Write a script that:

    1. Captures the current git branch with `git rev-parse --abbrev-ref HEAD`
    2. Captures the current commit hash with `git rev-parse --short HEAD`
    3. Captures the current timestamp with `date "+%Y-%m-%d %H:%M:%S"`
    4. Prints a formatted header:

        ```
        === Deployment Info ===
        Branch: main
        Commit: a1b2c3d
        Time:   2026-05-25 14:30:00
        ```

    ??? tip "Solution"
        ``` bash title="deployment-info.sh" linenums="1"
        #!/usr/bin/env bash

        branch=$(git rev-parse --abbrev-ref HEAD)
        commit=$(git rev-parse --short HEAD)
        timestamp=$(date "+%Y-%m-%d %H:%M:%S")

        echo "=== Deployment Info ==="
        echo "Branch: ${branch}"
        echo "Commit: ${commit}"
        echo "Time:   ${timestamp}"
        ```

---

## Quick Recap

- `name="value"` — no spaces around `=`; a space makes `name` a command
- Always quote variable expansions: `"${VAR}"` — prevents word splitting and empty-argument bugs
- Double quotes expand variables; single quotes are literal
- Variables come from your script, the environment, or Bash itself — knowing the source speeds up debugging
- `$(command)` captures command output — quote the result like any other variable
- `${VAR:-default}` for optional config; `${VAR:?message}` for required variables
- `export VAR` makes a variable visible to child processes; `readonly VAR` prevents reassignment

---

## Further Reading

### Command References

- `man bash` — search the "Parameter Expansion" section for the full list of `${VAR:-}` operators
- `man env` — how `env` works in shebangs and for setting per-command environment variables

### Deep Dives

- [Bash Pitfalls](https://mywiki.wooledge.org/BashPitfalls) — BashFAQ's list of common mistakes; many are quoting-related
- [Bash FAQ: Quoting](https://mywiki.wooledge.org/Quotes) — the Wooledge wiki's definitive guide to quoting

### Official Documentation

- [GNU Bash Manual: Shell Parameters](https://www.gnu.org/software/bash/manual/bash.html#Shell-Parameters) — all special variables
- [GNU Bash Manual: Command Substitution](https://www.gnu.org/software/bash/manual/bash.html#Command-Substitution)

---

## What's Next?

Head to **[Arguments and Exit Codes](bash_arguments.md)** — `$1`, `$@`, `$#`, exit codes, and how to make scripts composable with everything that calls them.
