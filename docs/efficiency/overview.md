---
date: "2026-07-30 12:00"
title: "Linux Efficiency: Namespaces, cgroups & Process Isolation"
description: "What actually isolates and limits a Linux process — namespaces, cgroups, capabilities, and the memory management that decides what gets killed when RAM runs out."
---

# Efficiency

Essentials got you fluent with the command line, permissions, and Bash. Efficiency goes underneath the commands, into the kernel mechanisms that make Linux processes behave the way they do — the same primitives that quietly run every container on every cluster.

Five categories planned; System is live first.

<div class="grid cards" markdown>

-   :material-monitor: **[System](namespaces_cgroups.md)**

    ---

    Namespaces and cgroups (the kernel isolation and limiting primitives behind every container), Linux capabilities (splitting root into ~40 distinct privileges), and what actually happens when the OOM killer takes a process out.

-   :material-console: **The Command Line** *(coming soon)*

    ---

    Shell shortcuts and command history — the muscle memory that separates fluent from functional.

-   :material-account-lock: **Users & Access** *(coming soon)*

    ---

    Deeper access control beyond the Essentials permission model.

-   :material-filter: **Text & Pipelines** *(coming soon)*

    ---

    `sed` and stream editing — transforming text, not just filtering it.

-   :material-file-code: **Bash Scripting** *(coming soon)*

    ---

    Safe scripts, `getopts`, trap/cleanup handlers, logging patterns, and parsing command output reliably.

</div>

---

## What's Next

Start with **[Namespaces and cgroups](namespaces_cgroups.md)** — the two kernel mechanisms everything else in System builds on.

After Efficiency, the **Mastery** track goes further into storage, LVM, network file shares, system tuning, and containers with Podman. *(Coming soon)*
