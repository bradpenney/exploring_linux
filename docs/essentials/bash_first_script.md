---
date: "2026-06-03 21:58"
title: "Your First Bash Script — From Shebang to Executable"
description: "Write your first Bash script with confidence. Covers the shebang line, script structure, making scripts executable, and where to store them for team use."
---

# Your First Bash Script

!!! tip "Part of Essentials — Bash Scripting"
    First in the Essentials Bash series. Assumes you're comfortable with the terminal — if you need a refresher, start with [Command Line Fundamentals](command_line_fundamentals.md). Next up: [Variables and Quoting](bash_variables.md).

You've been running the same sequences of commands manually. A Bash script captures that sequence, makes it repeatable, and lets you hand it to a colleague or a CI pipeline. The gap between "I know the commands" and "I wrote the script" is smaller than it looks.

---

## Where You've Seen This

If you've typed the same sequence of commands more than once, you've already felt the problem a script solves — it's just that sequence saved to a file and made repeatable. If you've used Windows batch files (`.bat`), the concept is identical; Linux just uses different syntax and `bash` is available everywhere by default.

---

## A First Script

``` bash title="system-info.sh" linenums="1"
#!/usr/bin/env bash

echo "=== System Information ==="
echo "User:     $(whoami)"
echo "Host:     $(hostname)"
echo "Date:     $(date)"
echo "Uptime:   $(uptime -p)"
echo "Disk:     $(df -h / | awk 'NR==2 {print $3 " used of " $2}')"
echo "Memory:   $(free -h | awk '/^Mem:/ {print $3 " used of " $2}')"
```

Three things to notice:

- `$(...)` runs a command and substitutes its output inline — covered in depth in [Variables and Quoting](bash_variables.md)
- `echo` sends output to stdout; pipelines and [redirection](pipes_and_redirection.md) work just like at the prompt
- There's no `main()` function — Bash runs top to bottom

---

## The Shebang Line

That first line — `#!/usr/bin/env bash` — tells the OS which interpreter to run the script with. Without it, the shell has to guess, and it can guess wrong.

=== "#!/usr/bin/env bash"

    Uses `env` to find `bash` in `$PATH`. Survives if `bash` is installed in a non-standard location — common on macOS, BSD, or NixOS. The portable choice.

    ``` bash title="Portable Shebang" linenums="1"
    #!/usr/bin/env bash
    ```

=== "#!/bin/bash"

    Absolute path to `bash` on most Linux systems. Slightly faster (skips the `env` lookup). Fine for scripts you know will only run on standard Linux.

    ``` bash title="Direct Path Shebang" linenums="1"
    #!/bin/bash
    ```

=== "#!/bin/sh"

    POSIX shell — not Bash. More portable across Unix systems but loses Bash-specific features like `[[ ]]`, arrays, and process substitution. Only use this if you genuinely need POSIX portability.

    ``` bash title="POSIX Shell Shebang" linenums="1"
    #!/bin/sh
    ```

=== "No shebang"

    The shell that *called* the script runs it. If your user's shell is `zsh`, the script runs as `zsh`. Unpredictable in automated contexts. Don't do this for scripts you'll share or schedule.

**The rule of thumb:** Use `#!/usr/bin/env bash` unless you have a specific reason to do otherwise.

---

## Making It Executable

A new file isn't executable by default. Two steps to run it:

``` bash title="Make a Script Executable" linenums="1"
chmod +x system-info.sh
./system-info.sh
```

The `./` prefix tells the shell "look here, not in PATH." Without it, the shell searches PATH and won't find your script unless you've added its directory.

!!! warning "Read scripts before running them"
    `chmod +x` and `./run.sh` is a common pattern in installation instructions. Read the script before executing it — it runs with your permissions.

See [File Permissions](file_permissions.md) for the full explanation of `chmod` and permission bits.

### Running Without chmod +x

You can also run a script by passing it directly to `bash`:

``` bash title="Run Without Executable Bit" linenums="1"
bash system-info.sh
```

This works even without `chmod +x`. Useful for quick tests, but the executable bit is the right approach for scripts you'll deploy or share.

---

## Where to Store Scripts

Where a script lives determines who can run it and how easily:

=== "Personal Scripts"

    For scripts only you need to run, install them to `~/bin` and add it to your PATH:

    ``` bash title="User-Scoped Scripts in ~/bin" linenums="1"
    mkdir -p ~/bin
    cp system-info.sh ~/bin/system-info
    chmod +x ~/bin/system-info
    ```

    Add `~/bin` to your PATH in `~/.bashrc`:

    ``` bash title="Add ~/bin to PATH" linenums="1"
    export PATH="$HOME/bin:$PATH"
    ```

    Now you can run `system-info` from anywhere without `./`.

=== "System-Wide Scripts"

    For scripts that all users on the system should access:

    ``` bash title="System-Wide Installation" linenums="1"
    sudo cp system-info.sh /usr/local/bin/system-info
    sudo chmod +x /usr/local/bin/system-info
    ```

    `/usr/local/bin/` is already in PATH for all users. Scripts here survive package manager updates (unlike `/usr/bin/`).

=== "Team Scripts"

    For shared tooling in a team environment:

    ``` bash title="Company Script Directory" linenums="1"
    sudo mkdir -p /opt/company/bin
    sudo cp system-info.sh /opt/company/bin/system-info
    sudo chmod +x /opt/company/bin/system-info
    ```

    Add `/opt/company/bin` to PATH system-wide via `/etc/profile.d/company.sh`. Putting shared scripts under `/opt/company/` keeps them out of package-managed paths and makes them easy to find.

---

## Practice Exercises

??? question "Exercise 1: Write a Health Check Script"
    Write a script called `health-check.sh` that prints the following in a formatted block:

    - Current user and hostname
    - Load average (use `uptime`)
    - Disk usage on `/` (use `df -h`)
    - Whether a specific process is running (use `pgrep -x sshd`)

    ??? tip "Solution"
        ``` bash title="health-check.sh" linenums="1"
        #!/usr/bin/env bash

        echo "=== Health Check: $(hostname) ==="
        echo "User:    $(whoami)"
        echo "Load:    $(uptime | awk -F'load average:' '{print $2}')"
        echo "Disk:    $(df -h / | awk 'NR==2 {print $5 " used (" $3 "/" $2 ")"}')"

        if pgrep -x sshd &>/dev/null; then
            echo "sshd:    running"
        else
            echo "sshd:    NOT RUNNING"
        fi
        ```

??? question "Exercise 2: Script Location Practice"
    Create a script called `whoami-full.sh` that prints your username, your primary group, and your home directory. Install it as a personal tool so you can run `whoami-full` from any directory without `./`.

    ??? tip "Solution"
        ``` bash title="whoami-full.sh" linenums="1"
        #!/usr/bin/env bash

        echo "User:  $(whoami)"
        echo "Group: $(id -gn)"
        echo "Home:  ${HOME}"
        ```

        Install it:

        ``` bash title="Install to ~/bin" linenums="1"
        mkdir -p ~/bin
        cp whoami-full.sh ~/bin/whoami-full
        chmod +x ~/bin/whoami-full
        # Ensure ~/bin is in PATH — add to ~/.bashrc if not already there:
        # export PATH="$HOME/bin:$PATH"
        whoami-full
        ```

---

## Quick Recap

- The shebang line (`#!/usr/bin/env bash`) tells Linux which interpreter to use — always include it
- `chmod +x script.sh` makes the file executable; `./script.sh` runs it
- `bash script.sh` runs a script without the executable bit — useful for one-off testing
- `~/bin/` for personal scripts, `/usr/local/bin/` for system-wide, `/opt/company/bin/` for team tooling
- Add the directory to `$PATH` so you can call scripts by name from anywhere

---

## Further Reading

### Command References

- `man bash` — the full Bash reference; the "INVOCATION" section covers how scripts are started
- `man chmod` — file permission bit reference

### Deep Dives

- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html) — the de-facto standard for team Bash scripts
- [The Art of Command Line](https://github.com/jlevy/the-art-of-command-line) — command line mastery, including scripting fundamentals

### Official Documentation

- [GNU Bash Manual](https://www.gnu.org/software/bash/manual/bash.html) — the authoritative Bash reference
- [Filesystem Hierarchy Standard](https://refspecs.linuxfoundation.org/FHS_3.0/fhs/index.html) — official spec for where things go on Linux

### Exploring Python

- [Why Python (Not Just Bash)](https://python.bradpenney.io/day_one/why_python/) — When your script grows into something bigger: the signals that mean Python is the right next step

---

## What's Next?

Head to **[Variables and Quoting](bash_variables.md)** — how to declare variables, why quoting prevents catastrophic bugs, and how command substitution captures runtime values.
