---
date: "2025-07-22 07:44"
title: Finding Help in Linux - man Pages, tldr, and Documentation
description: Learn to find help in Linux fast — man pages, --help flags, tldr, apropos, and the online resources every sysadmin keeps bookmarked.
---

# Finding Help

!!! tip "Part of Essentials"
    This article covers how to learn and look up commands. If you're trying to find documentation about a *specific system* you've been handed (configs, logs, git history), see [Finding Documentation](../day_one/finding_docs.md) in Day One.

You're on a server that's behaving unexpectedly. You find a command in a runbook that you've never used before — or you know the command but can't remember which flag does what you need. You could open a browser and search, but you're SSH'd into a server with no GUI, or the internet connection is locked down, or you're just faster when you don't leave the terminal.

The engineers who move fastest in Linux don't have better memory. They have a reliable lookup sequence that works offline, on any system, in under 30 seconds. This article gives you that sequence.

## Where You've Seen This

If you've used PowerShell, you know `Get-Help`. In Windows CMD, it's `command /?`. On Linux, the equivalent is `man`, and it's more powerful — but also more intimidating until you know how to navigate it efficiently.

The `--help` flag is essentially universal: it works in Python CLIs, Docker, kubectl, git, virtually every well-built command-line tool. You've already used it. The difference here is learning to use `man` for the cases where `--help` isn't enough, and `apropos` for when you don't know the command name at all.

Every Linux system ships with complete documentation for every installed command. No internet required. Once you know how to navigate it, you're self-sufficient anywhere.

---

## Choosing Your Source

``` mermaid
graph TD
    A[I need help with a command] --> B{How much do I need?}
    B -->|One-line summary| C["whatis\nQuick description"]
    B -->|Remind me of the flags| D["command --help\nFast flag reference"]
    B -->|Show me examples| E["tldr\nPractical examples"]
    B -->|Full reference| F["man\nComplete documentation"]
    B -->|I don't know the command name| G["man -k / apropos\nKeyword search"]

    style A fill:#d69e2e,stroke:#cbd5e0,stroke-width:2px,color:#000
    style C fill:#2d3748,stroke:#68d391,stroke-width:2px,color:#fff
    style D fill:#2d3748,stroke:#68d391,stroke-width:2px,color:#fff
    style E fill:#2d3748,stroke:#63b3ed,stroke-width:2px,color:#fff
    style F fill:#2d3748,stroke:#fc8181,stroke-width:2px,color:#fff
    style G fill:#2d3748,stroke:#d69e2e,stroke-width:2px,color:#fff
```

---

## The Tools

<div class="grid cards" markdown>

-   :material-help-circle: **--help — Fastest Flag Reference**

    ---

    **Why it matters:** When you remember a command exists but can't recall a specific flag, `--help` is the fastest lookup. It prints directly to your terminal — no pager, no navigation required.

    ``` bash title="Using --help"
    find --help
    grep --help
    systemctl --help
    ```

    **Key insight:** `--help` output is designed to be scanned, not read top-to-bottom. Look for the flag you need and move on. For commands where `--help` doesn't work, try `-h`.

    ``` bash title="When --help is Too Long"
    find --help | grep "\-name"     # (1)!
    find --help | less              # (2)!
    ```

    1. filter for the flag you need.
    2. page through it.

-   :material-information: **whatis — One-Line Summaries**

    ---

    **Why it matters:** `whatis` gives you a single-line description of any command — useful when you encounter something unfamiliar and need to know what it does before going further.

    ``` bash title="Using whatis"
    whatis find
    # find (1)              - search for files in a directory hierarchy

    whatis chmod
    # chmod (1)             - change file mode bits

    whatis passwd
    # passwd (1)            - change user password
    # passwd (5)            - password file
    ```

    **Key insight:** When `whatis` shows multiple results (like `passwd` above), the number in parentheses is the man page section. Section 1 is user commands; section 5 is file formats. You'll see how to use sections in the `man` section below.

-   :material-book-open: **man — Complete Documentation**

    ---

    **Why it matters:** Man pages are the authoritative reference for every command on the system. They cover every option, describe behavior edge cases, and are always accurate for the exact version installed.

    ``` bash title="Reading Man Pages"
    man find
    man chmod
    man 5 passwd    # (1)!
    man hier        # (2)!
    ```

    1. section 5: the `/etc/passwd` file format.
    2. the filesystem hierarchy standard.

    **Key insight:** Most people open a man page and feel overwhelmed. The next section covers how to read them efficiently without drowning in text.

-   :material-lightning-bolt: **tldr — Practical Examples First**

    ---

    **Why it matters:** `tldr` (Too Long; Didn't Read) shows common real-world examples for a command. It's community-maintained and cuts straight to the patterns you'll actually use.

    ``` bash title="Using tldr"
    tldr find
    # find
    # Find files or directories under the given directory tree, interactively.
    #
    # Find files by extension:
    #   find root_path -name '*.ext'
    #
    # Find files matching multiple path/name patterns:
    #   find root_path -name '*.ext' -or -name '*.py'
    ```

    **Installing tldr:**

    ``` bash title="Install tldr"
    # On RHEL/Fedora
    pip install tldr

    # On Ubuntu/Debian
    apt install tldr
    tldr --update   # (1)!
    ```

    1. download the page cache.

    **Key insight:** `tldr` is excellent for commands you use occasionally and can never quite remember the exact syntax for. It's faster than man pages for practical lookups.

</div>

---

## Reading Man Pages Effectively

Most people find man pages intimidating because they try to read them linearly. Don't. Man pages are reference documents — use them like a dictionary, not a novel.

### The Structure of a Man Page

Every man page follows roughly the same structure:

``` bash title="Open a Man Page"
man tar
```

| Section | What It Contains | When to Read It |
|---------|-----------------|-----------------|
| **NAME** | Command name and one-line description | Confirm you have the right page |
| **SYNOPSIS** | All usage patterns in compact notation | Find the pattern matching your use case |
| **DESCRIPTION** | What the command does, detailed | When you need to understand behavior |
| **OPTIONS** | Every flag explained | When you know the flag name |
| **EXAMPLES** | Real usage examples | Usually the fastest path to an answer |
| **FILES** | Configuration files and paths | When you need to find related files |
| **SEE ALSO** | Related commands | When this isn't quite what you needed |

### Reading the SYNOPSIS

The SYNOPSIS is the most information-dense part of a man page. It uses a compact notation:

``` bash title="Example SYNOPSIS from man find"
find [-H] [-L] [-P] [-D debugopts] [-Olevel] [starting-point...] [expression]
```

- `[-H]` — optional argument (square brackets = optional)
- `...` — can be repeated
- `starting-point` — required argument (no square brackets)
- `|` — choose one of these options (when present)

You don't need to read every option in the SYNOPSIS. Scan it to understand the basic shape: what's required, what's optional, what comes first.

### Navigating Inside man

``` bash title="Navigation Shortcuts Inside man"
/keyword        # search for "keyword" forward
?keyword        # search for "keyword" backward
n               # jump to next search match
N               # jump to previous match
q               # quit
Space           # page down
b               # page up
G               # jump to end of page
g               # jump to beginning
```

**The fastest workflow:** Open the man page, press `/` and search for the flag or topic you need, press `n` to cycle through matches, press `q` when done.

``` bash title="Practical Example: Finding the -exec Flag in man find"
man find
# Press: /-exec
# Press: n to cycle through results
# Found it — read the description, press q to quit
```

### Man Page Sections

Man pages are divided into numbered sections. The same name can appear in multiple sections with different meanings:

| Section | Contents |
|---------|----------|
| 1 | User commands (`ls`, `grep`, `find`) |
| 2 | System calls (`read`, `write`, `fork`) |
| 3 | Library functions (C standard library) |
| 4 | Device files (`/dev/null`, `/dev/sda`) |
| 5 | File formats (`/etc/passwd`, `/etc/fstab`) |
| 6 | Games |
| 7 | Miscellaneous (`regex`, `signal`, `man` conventions) |
| 8 | System administration (`mount`, `iptables`, `useradd`) |

``` bash title="Specifying Man Page Sections"
man passwd        # (1)!
man 5 passwd      # (2)!
man 8 useradd     # (3)!
```

1. defaults to section 1: the `passwd` command.
2. section 5: the `/etc/passwd` file format.
3. section 8: the `useradd` system administration command.

When you see a reference like `passwd(5)` in documentation, that means section 5 of the man page for `passwd`.

---

## Searching When You Don't Know the Command

You know what you want to do but not which command does it. Two tools help:

``` bash title="Keyword Search Across All Man Pages"
man -k "disk usage"
# df (1)                   - report file system disk space usage
# du (1)                   - estimate file space usage
# ncdu (1)                 - ncurses disk usage

apropos "network interface"
# ifconfig (8)             - configure a network interface
# ip (8)                   - show / manipulate routing, netns, devices, ...
# netstat (8)              - Print network connections, routing tables, ...
```

`man -k` and `apropos` are identical — they search man page descriptions by keyword. The output is `command (section) — description`.

``` bash title="Full-Text Search Across All Man Pages"
man -K "TCP_NODELAY"    # (1)!
```

1. capital `-K`: searches full text (slow but comprehensive).

`-K` (capital) searches the full text of every man page. It's slow, but useful when you know a specific term and want to find which commands or files use it.

---

## info Pages

Some GNU utilities (like `bash`, `gawk`, `grep`) have `info` pages in addition to man pages. Info pages are often more detailed and better organized for linear reading:

``` bash title="Using info Pages"
info bash       # (1)!
info grep       # (2)!
info coreutils  # (3)!
```

1. the full Bash reference manual.
2. grep's info documentation.
3. documentation for `ls`, `cp`, `mv`, and other coreutils.

Info uses its own navigation: `n` for next node, `p` for previous, `u` for up a level, `q` to quit. It's more like a book than a reference page.

??? tip "When to Use info vs man"
    Most engineers use `man` for quick lookups because it's faster to navigate. `info` is worth reading for commands you use heavily and want to understand deeply — especially `bash`, which has an excellent info manual.

---

## When Built-in Help Isn't Enough

Sometimes the man page doesn't have an example for your exact situation, or you're dealing with a tool that has sparse documentation. Reliable online sources:

=== "Distro-Specific Documentation"

    For questions about your specific distribution:

    - **Red Hat / RHEL / Fedora:** [access.redhat.com/documentation](https://access.redhat.com/documentation) — authoritative, deeply detailed
    - **Ubuntu / Debian:** [ubuntu.com/server/docs](https://ubuntu.com/server/docs) and [debian-handbook.info](https://debian-handbook.info/)
    - **Arch Linux Wiki:** [wiki.archlinux.org](https://wiki.archlinux.org) — excellent reference even for non-Arch systems

    !!! tip "The Arch Wiki Secret"
        The Arch Linux Wiki is widely considered the best Linux documentation on the internet — even if you're running RHEL or Ubuntu. The concepts are universal even when the package names differ.

=== "Universal References"

    For command syntax, system calls, and file formats:

    - **man7.org** — every Linux man page online, cross-referenced and searchable
    - **explainshell.com** — paste any command and get a visual explanation of each part
    - **GNU Coreutils Manual** — [gnu.org/software/coreutils/manual](https://www.gnu.org/software/coreutils/manual/) — authoritative docs for ls, cp, mv, find, and more

=== "Community Resources"

    When you have a specific error or unusual situation:

    - **Stack Overflow / Unix & Linux Stack Exchange** — searching the error message often finds a direct answer
    - **GitHub Issues** — for open source tools, project issues often document edge cases not in the man page
    - **Vendor documentation** — for products like nginx, PostgreSQL, Docker — always more detailed than man pages

---

## Quick Reference

### Help Tool Selection

| What You Need | Command | Speed |
|--------------|---------|-------|
| "What does this command do?" | `whatis command` | Instant |
| "What flags are available?" | `command --help` | Instant |
| "Show me common examples" | `tldr command` | Instant |
| "Full documentation" | `man command` | Opens pager |
| "Which section of man?" | `man whatis command` | Instant |
| "I don't know the command name" | `man -k keyword` or `apropos keyword` | Fast |
| "Find a specific term anywhere" | `man -K term` | Slow (full text) |
| "GNU tool deep dive" | `info command` | Opens pager |

### man Page Navigation

| Key | Action |
|-----|--------|
| `/keyword` | Search forward |
| `?keyword` | Search backward |
| `n` | Next match |
| `N` | Previous match |
| `Space` | Page down |
| `b` | Page up |
| `G` | End of page |
| `g` | Beginning of page |
| `q` | Quit |

---

## Practice Exercises

??? question "Exercise 1: Efficient man Page Lookup"
    You need to use `tar` to extract a `.tar.gz` file but can't remember the exact flags. Use `man tar` to find the answer in under 30 seconds without reading the whole page.

    ??? tip "Solution"
        ``` bash title="Finding tar Extract Syntax"
        man tar
        # Press: /extract
        # Or press: /EXAMPLES (look for examples section)
        # Or press: /-xzf (if you remember part of the syntax)
        ```

        The flags for extracting a `.tar.gz` file:

        ``` bash title="tar Extract"
        tar -xzf archive.tar.gz         # (1)!
        tar -xzf archive.tar.gz -C /dest/  # (2)!
        ```

        1. extract gzip-compressed tar.
        2. extract to specific directory.

        `-x` = extract, `-z` = gunzip, `-f` = filename follows

??? question "Exercise 2: Finding the Right Command"
    You need to convert text to uppercase but you don't know which Linux command does this. Use `man -k` to find it.

    ??? tip "Solution"
        ``` bash title="Finding a Command by Description"
        man -k "uppercase"
        # tr (1) - translate or delete characters

        man -k "case conversion"
        # awk (1p) - ...
        # tr (1) - translate or delete characters
        ```

        The command is `tr`:

        ``` bash title="Converting to Uppercase with tr"
        echo "hello world" | tr '[:lower:]' '[:upper:]'
        # HELLO WORLD
        ```

??? question "Exercise 3: Man Page Sections"
    The command `man crontab` shows one page, but there's also a `crontab(5)` that documents the file format. Open the file format documentation.

    ??? tip "Solution"
        ``` bash title="Opening a Specific Man Page Section"
        man crontab      # (1)!
        man 5 crontab    # (2)!

        # Check which sections exist
        whatis crontab
        # crontab (1)  - maintain crontab files for individual users
        # crontab (5)  - tables for driving cron
        ```

        1. section 1: the crontab command.
        2. section 5: the crontab file format.

---

## Quick Recap

- **`--help`** — fastest way to see flags; pipe to `grep` or `less` when it's too long
- **`whatis`** — one-line description; shows available man page sections
- **`tldr`** — community examples; install it if it's not there
- **`man`** — complete reference; navigate with `/keyword` not by reading top to bottom
- **`man -k` / `apropos`** — search when you don't know the command name
- **Man sections** — `man 5 passwd` accesses file formats; `man 8 useradd` accesses admin commands
- **Arch Wiki** — the best Linux documentation on the internet for any distribution

---

## Further Reading

### Command References

- `man man` — yes, the man page for man; useful for understanding section numbers and formatting
- `man apropos` — keyword search options
- `man whatis` — one-line description lookup
- `info info` — the info page for info navigation

### Deep Dives

- [man7.org](https://man7.org/linux/man-pages/) — Linux man pages online, cross-referenced
- [explainshell.com](https://explainshell.com/) — paste commands and see annotated explanations
- [Arch Linux Wiki](https://wiki.archlinux.org/) — comprehensive Linux documentation for any distro

### Official Documentation

- [GNU Coreutils Manual](https://www.gnu.org/software/coreutils/manual/) — authoritative reference for standard Unix utilities
- [Red Hat RHEL Documentation](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/) — RHEL system administration guides
- [Ubuntu Server Documentation](https://ubuntu.com/server/docs) — Ubuntu-specific server guides

---

## What's Next?

You can find any command, look it up efficiently, and get unstuck fast. Now it's time to understand the structure that underlies everything else in Linux: file permissions.

Head to **[File Permissions](file_permissions.md)** to learn how Linux controls who can read, write, and execute files — and how to manage permissions confidently without locking yourself (or your team) out.
