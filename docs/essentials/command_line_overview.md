---
title: "The Linux Command Line — Essentials Overview"
description: "Orient yourself in the Linux command line. Four articles covering navigation, the filesystem structure, finding files, and getting help when you're stuck."
---

# The Command Line

Before you can do anything useful on a Linux system, you need to know how to move, what you're looking at, and how to find things when you don't know where they are. These four articles build the mental model that everything else in Linux depends on.

``` mermaid
flowchart LR
    A["Command Line\nFundamentals"] --> B["Filesystem\nHierarchy"]
    B --> C["Finding Files"]
    A --> D["Finding Help"]

    style A fill:#1a202c,stroke:#cbd5e0,stroke-width:2px,color:#fff
    style B fill:#2d3748,stroke:#63b3ed,stroke-width:2px,color:#fff
    style C fill:#2d3748,stroke:#68d391,stroke-width:2px,color:#fff
    style D fill:#2d3748,stroke:#63b3ed,stroke-width:2px,color:#fff
```

<div class="grid cards" markdown>

-   :material-console: **[Command Line Fundamentals](command_line_fundamentals.md)**

    ---

    The commands you'll type on every session: navigation, file management, chaining, and the patterns that show up constantly in real work.

-   :material-file-tree: **[Filesystem Hierarchy](filesystem_hierarchy.md)**

    ---

    Why `/etc`, `/var`, `/usr`, and `/tmp` exist — and what you'll find (and break) in each.

-   :material-magnify: **[Finding Files](finding_files.md)**

    ---

    `find` and its real-world patterns: by name, type, age, size, and permission. The flags that matter in production.

-   :material-help-circle: **[Finding Help](finding_help.md)**

    ---

    Man pages, `--help`, `apropos`, and how to get answers without leaving the terminal.

</div>

---

## What's Next

Once you can navigate and find things, the next question is: who can touch them? Head to **[Users & Access](users_access_overview.md)** to understand Linux's permission model — the system that governs every file operation on the machine.
