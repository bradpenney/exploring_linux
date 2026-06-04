---
title: "Bash Arguments and Exit Codes — $1, $@, and $?"
description: "Handle script arguments and exit codes in Bash. Learn $1, $@, $#, $?, and how to return meaningful exit codes that other scripts and tools can act on."
---

# Arguments and Exit Codes

!!! tip "Part of Essentials — Bash Scripting"
    Third in the Essentials Bash series. Assumes you understand [Variables and Quoting](bash_variables.md). Next up: [Conditionals](bash_conditionals.md).

A script that only works with hardcoded values isn't a tool — it's a note to yourself. Arguments make scripts reusable. Exit codes make them composable: they let calling scripts, cron jobs, and monitoring systems know whether your script succeeded.

---

## Where You've Seen This

Windows batch files use `%1`, `%2`, `%3` for positional arguments — Bash uses `$1`, `$2`, `$3`. Exit codes are equally universal: every program returns one when it finishes (0 = success, non-zero = failure), and you've seen this whenever an installer aborted mid-way or a build stopped on error.

---

## Positional Arguments

Arguments passed on the command line are available as `$1`, `$2`, `$3`, and so on. Always assign them to named variables at the top of the script — `$1` is cryptic everywhere it appears; a named variable is self-documenting:

``` bash title="Using Positional Arguments" linenums="1"
#!/usr/bin/env bash
# Usage: ./deploy.sh <environment> <version>

environment="$1"  # (1)!
version="$2"      # (2)!

echo "Deploying version ${version} to ${environment}"
```

1. Assign `$1` to a named variable immediately — if `$1` appears ten lines later, nobody knows what it is.
2. Same for every positional argument. The rest of the script reads naturally.

``` bash title="Calling the Script" linenums="1"
./deploy.sh production 1.4.2  # (1)!
```

1. Output: `Deploying version 1.4.2 to production`

---

## The Argument Special Variables

<div class="grid cards" markdown>

-   :material-numeric-1-box: **`$1`, `$2`, ... `${N}`**

    ---

    Positional arguments. `$1` is the first argument, `$2` the second. For argument 10 and above, braces are required: `${10}`.

    ``` bash title="Positional Arguments" linenums="1"
    echo "First:  $1"
    echo "Second: $2"
    echo "Tenth:  ${10}"
    ```

-   :material-format-list-bulleted: **`"$@"`**

    ---

    All arguments as separate quoted strings — each one intact, regardless of content. Use when iterating over a list the caller supplies, or forwarding arguments to another command.

    ``` bash title="$@ in Practice" linenums="1"
    # Called as: ./check-servers.sh web-01 web-02 db-01

    for server in "$@"; do  # (1)!
        ping -c 1 "${server}" &>/dev/null \
            && echo "UP:   ${server}" \
            || echo "DOWN: ${server}"
    done
    ```

    1. Each argument the caller passed arrives as one intact item — no word splitting, no surprises.

-   :material-counter: **`$#`**

    ---

    The count of arguments. Validate it at the top of any script that requires specific input — fail immediately with a usage message rather than running with missing values.

    ``` bash title="Argument Count" linenums="1"
    if [[ $# -lt 2 ]]; then
        echo "Usage: $0 <environment> <version>" >&2
        exit 1
    fi
    ```

-   :material-script: **`$0`**

    ---

    The script's name as called. Use it in usage messages so the error always points to the right script, even when called via a symlink or from a different directory.

    ``` bash title="Script Name in Usage Message" linenums="1"
    echo "Usage: $0 <environment> <version>"  # (1)!
    ```

    1. Output: `Usage: ./deploy.sh <environment> <version>` — `$0` expands to the script name as called.

</div>

!!! tip "\"$@\" vs \"$*\""
    Almost always use `"$@"` — each argument stays a separate quoted string. Use `"$*"` only when you want all arguments joined into one string for display output, never for passing to another command.

---

## Exit Codes

Every command is a black box to its caller — input goes in, an exit code comes out. Your script is no different. When a cron job, a monitoring agent, or another script runs yours, the exit code is the only signal they get back.

The standard codes:

- **0** — success
- **1** — general error
- **2** — misuse of the command (wrong arguments)
- **126** — command found but not executable
- **127** — command not found
- **128+N** — killed by signal N

``` bash title="Checking Exit Codes" linenums="1"
grep "error" /var/log/app.log
echo "grep exit code: $?"    # (1)!

ls /nonexistent 2>/dev/null
echo "ls exit code: $?"      # (2)!
```

1. 0 if the pattern was found, 1 if not found, 2 if an error occurred.
2. Non-zero — the path doesn't exist.

### Setting Your Script's Exit Code

Call `exit 0` only if everything worked. Call `exit 1` the moment you know something went wrong — don't let the script continue:

``` bash title="Returning Exit Codes" linenums="1"
#!/usr/bin/env bash

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <hostname>" >&2
    exit 1                            # (1)!
fi

if ! ping -c 1 "$1" &>/dev/null; then
    echo "Host $1 is unreachable" >&2
    exit 1                            # (2)!
fi

echo "Host $1 is reachable"
exit 0                                # (3)!
```

1. Wrong number of arguments — exit immediately, before doing any work.
2. The check failed — exit with a non-zero code so callers know.
3. Technically redundant (a script that reaches the end exits 0), but explicit about intent.

### Using Exit Codes in the Calling Script

``` bash title="Acting on an Exit Code" linenums="1"
./check-host.sh db-prod-01
if [[ $? -ne 0 ]]; then               # (1)!
    echo "Database host is down" >&2
    exit 1
fi

if ! ./check-host.sh db-prod-01; then  # (2)!
    echo "Database host is down" >&2
    exit 1
fi
```

1. Checking `$?` explicitly — works, but `$?` is only valid immediately after the command. Any intervening command overwrites it.
2. Using the command directly as the condition — cleaner and safer. This is the preferred style.

---

## Real-World Argument Patterns

=== "Validate Required Arguments"

    Most scripts require specific arguments. Check `$#` at the start and fail immediately with a usage message — never let the script run with missing input:

    ``` bash title="Argument Validation" linenums="1"
    #!/usr/bin/env bash

    usage() {
        echo "Usage: $0 <environment> <version>" >&2
        echo "" >&2
        echo "  environment: production | staging | dev" >&2
        echo "  version:     semantic version (e.g., 1.4.2)" >&2
        exit 1
    }

    if [[ $# -ne 2 ]]; then
        usage
    fi

    environment="$1"
    version="$2"

    echo "Deploying ${version} to ${environment}"
    ```

=== "Optional Arguments with Defaults"

    When arguments are optional, use default values to fall back gracefully rather than requiring the caller to always supply everything:

    ``` bash title="Arguments with Defaults" linenums="1"
    #!/usr/bin/env bash

    environment="${1:-staging}"  # (1)!
    timeout="${2:-30}"           # (2)!

    echo "Target:  ${environment}"
    echo "Timeout: ${timeout}s"
    ```

    1. If no first argument, default to `staging`.
    2. If no second argument, default to 30 seconds.

=== "Pass-Through Arguments"

    Wrapper scripts take fixed arguments for themselves and forward the rest to another command. `shift` consumes the fixed arguments, leaving `"$@"` as the remainder:

    ``` bash title="Forwarding Arguments with shift" linenums="1"
    #!/usr/bin/env bash
    # Wrapper around rsync that always uses compression and archive mode

    if [[ $# -lt 2 ]]; then
        echo "Usage: $0 <source> <destination> [rsync-options...]" >&2
        exit 1
    fi

    source="$1"
    destination="$2"
    shift 2    # (1)!

    rsync -az "$@" "${source}" "${destination}"  # (2)!
    ```

    1. Removes the first two arguments. What was `$3` is now `$1`.
    2. `"$@"` now contains only the caller-supplied options, forwarded intact.

When your interface grows to flag-style arguments — `--environment production`, `--dry-run`, `--help` — that's the natural handoff point. Python's `click` library handles flags, validation, and `--help` generation in a way `$1`/`$@` patterns can't scale to. See [My Bash Script Is Getting Out of Hand](https://python.bradpenney.io/day_one/wrapping_bash/).

---

## Practice Exercises

??? question "Exercise 1: Write an Argument Validator"
    Write a script called `backup.sh` that:

    1. Requires exactly two arguments: a source directory and a destination directory
    2. Prints a helpful usage message to stderr and exits with code 1 if the wrong number of arguments is given
    3. Prints `"Backing up /source to /destination"` when called correctly

    ??? tip "Solution"
        ``` bash title="backup.sh" linenums="1"
        #!/usr/bin/env bash

        if [[ $# -ne 2 ]]; then
            echo "Usage: $0 <source-dir> <destination-dir>" >&2
            exit 1
        fi

        source_dir="$1"
        destination_dir="$2"

        echo "Backing up ${source_dir} to ${destination_dir}"
        ```

??? question "Exercise 2: Exit Code Chain"
    Write a script called `preflight.sh` that checks three conditions and exits with code 1 if any fails, or code 0 if all pass:

    1. Argument `$1` is provided (a hostname)
    2. The `curl` command is available (use `command -v curl`)
    3. The hostname is reachable (use `ping -c 1 $1`)

    Print a specific error message for each failure.

    ??? tip "Solution"
        ``` bash title="preflight.sh" linenums="1"
        #!/usr/bin/env bash

        if [[ $# -lt 1 ]]; then
            echo "Usage: $0 <hostname>" >&2
            exit 1
        fi

        host="$1"

        if ! command -v curl &>/dev/null; then
            echo "Error: curl is not installed" >&2
            exit 1
        fi

        if ! ping -c 1 "${host}" &>/dev/null; then
            echo "Error: ${host} is not reachable" >&2
            exit 1
        fi

        echo "All preflight checks passed"
        exit 0
        ```

---

## Quick Recap

- Always assign `$1`, `$2` to named variables at the top — positional numbers are cryptic in the middle of a script
- `$#` — argument count; validate at the start, fail immediately with a usage message
- `"$@"` — all arguments, each properly quoted; use when passing arguments to another command
- `$0` — the script's name; use it in usage messages
- Exit codes are your script's only signal to callers — 0 means success, non-zero means failure
- Use `if ! ./script.sh; then` rather than checking `$?` explicitly — cleaner and `$?` can be overwritten
- Write error messages to stderr: `echo "Error" >&2` — covered in [Pipes and Redirection](pipes_and_redirection.md)

---

## Further Reading

### Command References

- `man bash` — the "Special Parameters" section documents `$@`, `$*`, `$#`, `$?`, `$$`, and `$0`
- `help shift` — documentation for the `shift` builtin

### Deep Dives

- [Bash FAQ: Capture Output and Exit Status](https://mywiki.wooledge.org/BashFAQ/002) — Wooledge on storing command output and checking `$?`
- [Process Exit Status](https://www.gnu.org/software/bash/manual/bash.html#Exit-Status) — GNU manual on how exit status flows through pipelines

### Official Documentation

- [GNU Bash Manual: Special Parameters](https://www.gnu.org/software/bash/manual/bash.html#Special-Parameters)
- [GNU Bash Manual: Exit Status](https://www.gnu.org/software/bash/manual/bash.html#Exit-Status)

### Exploring Python

- [My Bash Script Is Getting Out of Hand](https://python.bradpenney.io/day_one/wrapping_bash/) — When `$1`/`$@` handling grows unwieldy: migrating argument-heavy scripts to Python with proper parsing and `--help` output

---

## What's Next?

Head to **[Conditionals](bash_conditionals.md)** — `if/elif/else`, the `[[ ]]` operator, and the tests that drive the logic of every real Bash script.
