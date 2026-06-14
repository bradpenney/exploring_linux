---
date: "2026-06-03 21:58"
title: "Bash Loops — for, while, and Iterating Command Output"
description: "Master Bash loops for automation. Covers for loops over lists and files, while loops with command output, break and continue, and practical loop patterns."
---

# Loops

!!! tip "Part of Essentials — Bash Scripting"
    Fifth in the Essentials Bash series. Assumes you understand [Conditionals](bash_conditionals.md). Next up: [Functions](bash_functions.md).

Loops are where scripting shifts from "commands in a file" to actual automation. Instead of running a command once, you run it against every server in a list, every log file in a directory, or every line of output from another command.

---

## Where You've Seen This

If you've ever run the same command against a list of servers one at a time, you've already felt the problem loops solve — a loop is that repetition captured in a script. Windows batch files have `FOR /F`, every scripting language has the same concept; Bash just has two forms depending on whether you know the list upfront.

---

## The for Loop

Use `for` when you have a defined list to work through — servers to ping, files to process, values to validate. The list can be hardcoded, a glob pattern, an array, or a numeric range.

### Iterating Over a List

``` bash title="Basic for Loop" linenums="1"
servers=("web-01" "web-02" "db-01")

for server in "${servers[@]}"; do   # (1)!
    ping -c 1 "${server}" &>/dev/null \
        && echo "UP:   ${server}" \
        || echo "DOWN: ${server}"
done
```

1. Always quote `"${array[@]}"` — without quotes, elements with spaces split into separate words.

### Iterating Over Files

The most common real-world use — process every file matching a glob pattern:

``` bash title="Loop Over Files" linenums="1"
for logfile in /var/log/nginx/*.log; do
    echo "Processing: ${logfile}"
    wc -l "${logfile}"
done
```

!!! warning "When No Files Match"
    If `*.log` matches nothing, Bash passes the literal string `*.log` to your loop as the first item. Use `shopt -s nullglob` to expand an empty glob to nothing:

    ``` bash title="Safe Glob Handling" linenums="1"
    shopt -s nullglob   # (1)!
    for logfile in /var/log/nginx/*.log; do
        wc -l "${logfile}"
    done
    shopt -u nullglob   # (2)!
    ```

    1. Unmatched globs now expand to nothing — the loop body never runs if there are no files.
    2. Restore default behaviour after the loop.

### Iterating Over a Range

=== "Brace range"

    ``` bash title="Numeric Range" linenums="1"
    for i in {1..10}; do
        echo "Iteration ${i}"
    done
    ```

=== "With step"

    ``` bash title="Range with Step Size" linenums="1"
    for i in {0..100..10}; do
        echo "${i}%"
    done
    ```

=== "C-style"

    Use the C-style form when you need the index for arithmetic or need to control the step precisely:

    ``` bash title="C-Style for Loop" linenums="1"
    for (( i=0; i<5; i++ )); do
        echo "Index: ${i}"
    done
    ```

---

## The while Loop

Use `while` when you don't know the list size upfront — reading a file line by line, waiting for a condition to become true, or processing a stream of unknown length.

``` bash title="Basic while Loop" linenums="1"
count=1
while [[ ${count} -le 5 ]]; do
    echo "Count: ${count}"
    (( count++ ))
done
```

### Reading a File Line by Line

This is the canonical safe pattern — every part matters:

``` bash title="Read File Line by Line" linenums="1"
while IFS= read -r line; do   # (1)!
    echo "Line: ${line}"
done < "/path/to/file.txt"    # (2)!
```

1. `IFS=` clears the field separator so leading/trailing whitespace is preserved. `read -r` prevents backslash from being treated as an escape character.
2. Redirects the file into the loop's stdin — the loop reads it line by line without a subshell.

### Reading Command Output

When the input is a live command rather than a file, use process substitution to feed it to the loop:

``` bash title="Read Command Output Line by Line" linenums="1"
while IFS= read -r pod; do
    echo "Restarting: ${pod}"
    kubectl delete "${pod}"
done < <(kubectl get pods --field-selector=status.phase=Failed -o name)   # (1)!
```

1. `< <(command)` is **process substitution** — it runs the command and presents its output as a file-like stream. Unlike piping to `while` (which runs the loop in a subshell), this keeps any variables you set inside the loop visible in the parent shell.

---

## Loop Control

`break` and `continue` let you short-circuit a loop without restructuring the whole block:

``` bash title="break and continue" linenums="1"
for file in /var/log/*.log; do
    if [[ ! -s "${file}" ]]; then
        continue   # (1)!
    fi

    if [[ "${file}" == *"debug"* ]]; then
        break      # (2)!
    fi

    echo "Processing: ${file}"
done
```

1. Skip empty files — move straight to the next iteration.
2. Stop the loop entirely when a debug log is reached.

---

## Real-World Loop Patterns

The patterns below draw on commands covered in other Essentials articles — [`grep`](grep.md) for filtering and [`find`](finding_files.md) for file discovery.

=== "Server Health Check"

    Iterate over a list of servers, track failures, and exit with a non-zero code if any are unreachable — making the script composable with monitoring and alerting tools:

    ``` bash title="Check a List of Servers" linenums="1"
    #!/usr/bin/env bash

    servers=("web-01" "web-02" "web-03" "db-01")
    failed=0

    for server in "${servers[@]}"; do
        if ping -c 1 -W 2 "${server}" &>/dev/null; then
            echo "OK:   ${server}"
        else
            echo "FAIL: ${server}"
            (( failed++ ))
        fi
    done

    if [[ ${failed} -gt 0 ]]; then
        echo "${failed} server(s) unreachable" >&2
        exit 1
    fi

    echo "All servers reachable"
    ```

=== "Log File Batch Processing"

    Process every log file in a directory and write a summary report — the kind of script that runs nightly from cron:

    ``` bash title="Summarise Every Log File" linenums="1"
    #!/usr/bin/env bash

    log_dir="${1:-/var/log/nginx}"
    report_file="/tmp/log-report-$(date +%Y%m%d).txt"

    shopt -s nullglob
    for logfile in "${log_dir}"/*.log; do
        size=$(du -sh "${logfile}" | cut -f1)
        lines=$(wc -l < "${logfile}")
        errors=$(grep -c " 5[0-9][0-9] " "${logfile}" 2>/dev/null || echo 0)
        echo "${logfile}: ${lines} lines, ${size}, ${errors} 5xx errors"
    done >> "${report_file}"
    shopt -u nullglob

    echo "Report written to: ${report_file}"
    ```

=== "Retry Loop with Backoff"

    Wait for a service to become available, retrying with increasing delays. Essential for deployment scripts that start a service and then need to use it:

    ``` bash title="Wait for a Service to Come Up" linenums="1"
    #!/usr/bin/env bash

    max_attempts=5
    attempt=1

    while [[ ${attempt} -le ${max_attempts} ]]; do
        echo "Attempt ${attempt}/${max_attempts}..."

        if curl -sf "https://api.example.com/health" &>/dev/null; then
            echo "Service is up"
            exit 0
        fi

        echo "Not ready yet, waiting..."
        sleep $(( attempt * 5 ))   # (1)!
        (( attempt++ ))
    done

    echo "Service did not come up after ${max_attempts} attempts" >&2
    exit 1
    ```

    1. Increasing backoff: 5s, 10s, 15s, 20s, 25s — gives the service more time on each retry.

---

## Practice Exercises

??? question "Exercise 1: Count Files by Extension"
    Write a script that accepts a directory as its argument and prints the count of files with each of these extensions: `.log`, `.gz`, and `.txt`.

    ??? tip "Solution"
        ``` bash title="count-by-extension.sh" linenums="1"
        #!/usr/bin/env bash

        dir="${1:-.}"

        for ext in log gz txt; do
            count=$(find "${dir}" -maxdepth 1 -name "*.${ext}" | wc -l)
            echo ".${ext}: ${count} files"
        done
        ```

        `find`'s full search options — filtering by age, type, and size — are covered in [Finding Files](finding_files.md).

??? question "Exercise 2: Process a Server List File"
    Write a script that reads a file of hostnames (one per line, `#` lines are comments) and for each hostname:

    1. Skips blank lines and lines starting with `#`
    2. Prints `OK: <hostname>` if ping succeeds
    3. Prints `FAIL: <hostname>` if ping fails
    4. Exits with a code equal to the number of failed hosts (0 if all pass)

    ??? tip "Solution"
        ``` bash title="check-hosts.sh" linenums="1"
        #!/usr/bin/env bash

        hosts_file="${1:-hosts.txt}"
        failed=0

        while IFS= read -r host; do
            [[ -z "${host}" || "${host}" == \#* ]] && continue

            if ping -c 1 -W 2 "${host}" &>/dev/null; then
                echo "OK:   ${host}"
            else
                echo "FAIL: ${host}"
                (( failed++ ))
            fi
        done < "${hosts_file}"

        exit ${failed}
        ```

---

## Quick Recap

- Use `for` when you have a defined list — hardcoded, a glob, an array, or a range
- Use `while` when you don't know the size upfront — file input, streams, retry loops
- `while IFS= read -r line; do ... done < file` — the correct pattern for reading files line by line
- `< <(command)` — process substitution; feeds command output to a loop without a subshell
- `shopt -s nullglob` before glob loops — prevents the literal glob string when no files match
- Quote array expansions: `"${array[@]}"` — prevents word splitting on elements with spaces
- `break` exits the loop; `continue` skips to the next iteration

---

## Further Reading

### Command References

- `man bash` — the "Looping Constructs" section covers `for`, `while`, `until`, and `select`
- `help read` — documentation for the `read` builtin, including all flags

### Deep Dives

- [Bash FAQ: How do I read a file line by line?](https://mywiki.wooledge.org/BashFAQ/001) — the authoritative guide to the `IFS= read -r` pattern
- [Process Substitution](https://mywiki.wooledge.org/ProcessSubstitution) — Wooledge wiki on `< <(command)` and when to use it

### Official Documentation

- [GNU Bash Manual: Looping Constructs](https://www.gnu.org/software/bash/manual/bash.html#Looping-Constructs)
- [GNU Bash Manual: Process Substitution](https://www.gnu.org/software/bash/manual/bash.html#Process-Substitution)

### Exploring Python

- [What Just Broke?](https://python.bradpenney.io/day_one/parsing_logs/) — When `while IFS= read -r` hits its limit: structured log parsing in Python with pattern matching and output you can actually act on
- [Run This Everywhere](https://python.bradpenney.io/day_one/run_everywhere/) — When your loop-over-hosts script needs parallelism or structured error handling across the fleet

---

## What's Next?

Head to **[Functions](bash_functions.md)** — how to group reusable logic, scope variables with `local`, and structure larger scripts with the `main "$@"` pattern.
