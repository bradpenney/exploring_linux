---
date: "2026-06-03 21:58"
title: "Users and Access in Linux — Essentials Overview"
description: "Master Linux's permission model. Two articles covering file permissions and user/group management — the foundation of every access control decision on Linux."
---

# Users & Access

Every operation on a Linux system is governed by three things: who you are, what group you belong to, and what the file allows. The two articles here cover both sides of that equation — the permission model itself, and the identity system behind it.

<div class="grid cards" markdown>

-   :material-lock: **[File Permissions](file_permissions.md)**

    ---

    Read the `rwxr-xr-x` strings, change permissions with `chmod`, and understand the difference between symbolic and octal notation — and when each is right.

-   :material-account-group: **[Users and Groups](users_and_groups.md)**

    ---

    Add users, manage groups, switch identities with `sudo` and `su`, and understand how Linux maps identity to access at runtime.

</div>

---

## What's Next

With permissions and identity in hand, the next step is working with data. Head to **[Text & Pipelines](text_pipelines_overview.md)** — the Linux tools for filtering, routing, and searching the output of any command.
