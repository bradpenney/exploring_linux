---
title: "Bash Functions — Reusable Blocks for Better Scripts"
description: "Organise Bash scripts with functions. Learn to define, call, and scope functions with local variables, return values via exit codes, and reuse patterns."
---

# Functions

!!! tip "Part of Essentials — Bash Scripting"
    Sixth and final article in the Essentials Bash series. Assumes you understand [Loops](bash_loops.md). The next step is the Efficiency tier, which covers production-grade patterns like `set -euo pipefail`, signal handling, and structured logging.

As scripts grow past 20-30 lines, repeated logic becomes a maintenance problem. A check you run in three places has to be updated in three places. Functions solve this: write the logic once, call it from anywhere, and give it a name that makes the script self-documenting.

---

## Where You've Seen This

If you've ever sourced a setup script (`source ~/.bashrc` or `. ./env-setup.sh`), you've already used a function library — that file defines functions your shell loads and can call by name. Writing your own is the same pattern.

---

## Defining and Calling Functions

``` bash title="Function Definition" linenums="1"
check_host() {        # (1)!
    local host="$1"
    ping -c 1 "${host}" &>/dev/null
}
```

1. `name() { }` is the standard form. An alternative `function name { }` syntax exists but adds nothing — the first is what you'll see in most scripts.

Call a function exactly like any other command:

``` bash title="Calling a Function" linenums="1"
check_host "web-01"   # (1)!
```

1. Arguments work the same as script arguments — `$1`, `$2`, `"$@"` inside the function refer to what was passed here.

**Define before you call.** Bash reads top to bottom — a function must appear in the file before any line that calls it. The standard pattern: define all functions at the top, put the calling code at the bottom.

---

## Arguments and Local Variables

Functions receive arguments exactly as scripts do — `$1`, `$2`, `$@`, `$#`. Always declare function variables with `local` — without it, they're global and will overwrite variables with the same name in the main script or other functions:

``` bash title="local Variables" linenums="1"
counter=10

increment() {
    counter=$(( counter + 1 ))  # (1)!
}

safe_reset() {
    local counter=0             # (2)!
    echo "Local: ${counter}"
}

increment
echo "${counter}"               # (3)!

safe_reset
echo "${counter}"               # (4)!
```

1. No `local` — this modifies the global `counter`.
2. `local` creates a separate variable scoped to this function. The global is untouched.
3. Output: `11` — `increment` changed the global.
4. Output: `11` — `safe_reset` did not, because its `counter` was local.

**Rule:** declare all function variables with `local`.

---

## Return Values

Bash functions return exit codes (integers 0–255), not values. How you get data back to the caller depends on what you need to return:

=== "Exit Code"

    The natural way to signal pass/fail. Works directly with `if`, `&&`, `||`, and the guard-first patterns from [Conditionals](bash_conditionals.md):

    ``` bash title="Return via Exit Code" linenums="1"
    is_port_open() {
        local host="$1"
        local port="$2"
        nc -z "${host}" "${port}" &>/dev/null  # (1)!
    }

    if is_port_open "db-prod-01" 5432; then
        echo "Database port is open"
    fi
    ```

    1. The last command's exit code becomes the function's return value. `nc` exits 0 if the port is open, non-zero if not — so the function inherits that result automatically.

=== "String via echo"

    When you need to return a string rather than just pass/fail, `echo` the value and capture it with command substitution in the caller:

    ``` bash title="Return a String via echo" linenums="1"
    get_timestamp() {
        echo "$(date '+%Y-%m-%d %H:%M:%S')"  # (1)!
    }

    log_entry() {
        local message="$1"
        local timestamp
        timestamp=$(get_timestamp)            # (2)!
        echo "[${timestamp}] ${message}"
    }

    log_entry "Deployment started"
    ```

    1. `echo` to stdout is the only way to return a string from a Bash function.
    2. The caller captures it with `$()` — the same command substitution used anywhere else.

=== "Global Variable"

    Use only when a function needs to return multiple values. It creates invisible coupling between the function and its callers — document it clearly:

    ``` bash title="Return via Global Variable" linenums="1"
    parse_version() {
        local version="$1"
        MAJOR="${version%%.*}"           # (1)!
        MINOR="${version#*.}"
        MINOR="${MINOR%%.*}"
        PATCH="${version##*.}"           # (2)!
    }

    parse_version "2.14.3"
    echo "Major: ${MAJOR}, Minor: ${MINOR}, Patch: ${PATCH}"
    ```

    1. Sets globals directly — uppercase names signal that these are intentional globals.
    2. After the call, `MAJOR`, `MINOR`, and `PATCH` are available in the caller's scope.

---

## Practical Function Patterns

=== "Logging Functions"

    A logging function is the most universally useful thing to add to any script — timestamps and severity without repeating `date` everywhere:

    ``` bash title="Structured Logging" linenums="1"
    #!/usr/bin/env bash

    log_info() {
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO:  $*"   # (1)!
    }

    log_error() {
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*" >&2
    }

    log_info "Starting deployment"
    log_error "Connection refused to db-prod-01"
    ```

    1. `$*` joins all arguments into one string — appropriate for a log message, which is a single unit.

=== "Validation Functions"

    Extracting guard checks into named functions keeps `main()` readable — the top-level flow reads as intent, not implementation:

    ``` bash title="Reusable Validation" linenums="1"
    #!/usr/bin/env bash

    require_command() {
        local cmd="$1"
        if ! command -v "${cmd}" &>/dev/null; then
            echo "Error: required command '${cmd}' is not installed" >&2
            exit 1
        fi
    }

    require_file() {
        local path="$1"
        if [[ ! -f "${path}" ]]; then
            echo "Error: required file not found: ${path}" >&2
            exit 1
        fi
    }

    require_command curl
    require_command jq
    require_file "/etc/myapp/config.yml"

    echo "All prerequisites met"
    ```

=== "Main Function Pattern"

    For any script beyond a few functions, wrap the entry point in `main()` and call it at the bottom. This means nothing runs on source — every top-level statement is a function definition until `main "$@"`:

    ``` bash title="main() Pattern" linenums="1"
    #!/usr/bin/env bash

    log_info() { echo "[$(date '+%H:%M:%S')] $*"; }

    setup() {
        log_info "Checking prerequisites..."
        command -v curl &>/dev/null || { echo "Error: curl required" >&2; exit 1; }
    }

    deploy() {
        local version="$1"
        log_info "Deploying version ${version}..."
    }

    verify() {
        log_info "Verifying deployment..."
    }

    main() {
        local version="${1:?Error: version argument required}"
        setup
        deploy "${version}"
        verify
        log_info "Done"
    }

    main "$@"   # (1)!
    ```

    1. The only line that runs directly — passes all script arguments to `main`. Everything above is a definition.

---

## Sourcing Function Libraries

When functions are useful across multiple scripts, put them in a shared file and load it with `source`:

``` bash title="lib/functions.sh" linenums="1"
#!/usr/bin/env bash

log_info()  { echo "[$(date '+%H:%M:%S')] INFO:  $*"; }
log_error() { echo "[$(date '+%H:%M:%S')] ERROR: $*" >&2; }

require_command() {
    local cmd="$1"
    command -v "${cmd}" &>/dev/null || { log_error "${cmd} not found"; exit 1; }
}
```

``` bash title="deploy.sh" linenums="1"
#!/usr/bin/env bash

source "$(dirname "$0")/lib/functions.sh"   # (1)!

log_info "Starting deployment"
require_command curl
require_command jq
```

1. `$(dirname "$0")` resolves to the directory containing the running script — a reliable way to find sibling files without hardcoding absolute paths.

---

## Practice Exercises

??? question "Exercise 1: Refactor to Functions"
    This script has repetitive code. Refactor it using a function:

    ``` bash title="Before — Repetitive" linenums="1"
    #!/usr/bin/env bash

    if ping -c 1 "web-01" &>/dev/null; then
        echo "web-01: UP"
    else
        echo "web-01: DOWN"
    fi

    if ping -c 1 "web-02" &>/dev/null; then
        echo "web-02: UP"
    else
        echo "web-02: DOWN"
    fi

    if ping -c 1 "db-01" &>/dev/null; then
        echo "db-01: UP"
    else
        echo "db-01: DOWN"
    fi
    ```

    ??? tip "Solution"
        ``` bash title="After — With Function" linenums="1"
        #!/usr/bin/env bash

        check_host() {
            local host="$1"
            if ping -c 1 "${host}" &>/dev/null; then
                echo "${host}: UP"
            else
                echo "${host}: DOWN"
            fi
        }

        check_host "web-01"
        check_host "web-02"
        check_host "db-01"
        ```

??? question "Exercise 2: Function That Returns a Value"
    Write a function called `get_disk_usage` that:

    1. Accepts a directory path as its argument
    2. Returns (via `echo`) the disk usage as a percentage — just the number, e.g. `63`
    3. In `main()`, call the function and print: `"/ is 63% full"`

    ??? tip "Solution"
        ``` bash title="disk-check.sh" linenums="1"
        #!/usr/bin/env bash

        get_disk_usage() {
            local path="$1"
            df "${path}" | awk 'NR==2 {gsub(/%/, ""); print $5}'
        }

        main() {
            local usage
            usage=$(get_disk_usage "/")
            echo "/ is ${usage}% full"
        }

        main
        ```

---

## Quick Recap

- `name() { }` is the standard function syntax — define before you call
- Always use `local` for function variables — undeclared variables are global and will cause subtle bugs
- Function arguments work exactly like script arguments: `$1`, `$2`, `"$@"`
- Return pass/fail via exit code; return strings via `echo` + `$()`; avoid globals except for multiple return values
- `main "$@"` at the bottom of a script: the only line that runs directly, everything else is a definition
- Shared functions go in a library file, loaded with `source "$(dirname "$0")/lib.sh"`

---

## Further Reading

### Command References

- `man bash` — the "Functions" section and the `local` and `source` builtins
- `help local` — Bash built-in help for the `local` keyword
- `help source` — how `source` (or `.`) loads function files

### Deep Dives

- [Google Shell Style Guide: Functions](https://google.github.io/styleguide/shellguide.html) — naming conventions, structure, and when to use functions
- [BashGuide: Functions](https://mywiki.wooledge.org/BashGuide/CompoundCommands) — Wooledge guide to functions, local scope, and practical usage

### Official Documentation

- [GNU Bash Manual: Shell Functions](https://www.gnu.org/software/bash/manual/bash.html#Shell-Functions)
- [GNU Bash Manual: The local builtin](https://www.gnu.org/software/bash/manual/bash.html#index-local)

---

## What's Next?

You've covered the complete Bash scripting foundation: scripts, variables, arguments, conditionals, loops, and functions. The Efficiency tier builds on these with patterns for production-grade scripts — `set -euo pipefail`, `getopts`, signal handling, and structured logging — coming soon.
