---
date: "2026-06-03 21:58"
title: "Essentials — Linux for IT Professionals"
description: "The Linux commands and concepts every sysadmin and platform engineer must own. Five categories from command line fundamentals to Bash scripting automation."
---

# Essentials

You know IT. You've administered Windows, worked with Active Directory, written PowerShell, managed infrastructure. Linux uses different tools and different conventions — this track covers what you specifically need to know.

Five categories, built in order. Each one unlocks the next.

``` mermaid
flowchart LR
    A["The\nCommand Line"] --> B["Users\n& Access"]
    B --> C["Text &\nPipelines"]
    C --> D["System"]
    D --> E["Bash\nScripting"]

    style A fill:#1a202c,stroke:#cbd5e0,stroke-width:2px,color:#fff
    style B fill:#2d3748,stroke:#cbd5e0,stroke-width:2px,color:#fff
    style C fill:#2d3748,stroke:#cbd5e0,stroke-width:2px,color:#fff
    style D fill:#2d3748,stroke:#cbd5e0,stroke-width:2px,color:#fff
    style E fill:#2f855a,stroke:#cbd5e0,stroke-width:2px,color:#fff
```

<div class="grid cards" markdown>

-   :material-console: **[The Command Line](command_line_overview.md)**

    ---

    Navigation, the filesystem layout, finding files, and getting help. The mental model every other Linux skill depends on.

-   :material-account-lock: **[Users & Access](users_access_overview.md)**

    ---

    The Linux permissions model — chmod, chown, umask, SUID, SGID, and user and group management.

-   :material-filter: **[Text & Pipelines](text_pipelines_overview.md)**

    ---

    Stdin, stdout, stderr, pipes, redirection, and grep. The Unix toolkit for slicing and searching any text output.

-   :material-monitor: **[System](system_overview.md)**

    ---

    Process inspection, signals, job control, and resource monitoring — controlling what's running and why.

-   :material-file-code: **[Bash Scripting](bash_scripting.md)**

    ---

    Six articles from first script to reusable functions. The commands you've learned become automation tools.

</div>

---

## What's Next

After Essentials, the **Efficiency** track covers the tools that experienced Linux professionals reach for daily: systemd for service management, `sed` for text transformation, and package management. *(Coming soon)*
