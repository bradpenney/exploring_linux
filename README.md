# Exploring Enterprise Linux

**From nervous SSH login to confident system administration.**

A subsection of [BradPenney.io](https://bradpenney.io), this site teaches practical Linux skills for developers and system administrators. It emphasizes real-world scenarios, production safety, and understanding the "why" behind every command.

**Live Site:** https://linux.bradpenney.io

## Where This Fits in the bradpenney.io Network

Linux is the foundation layer — every other site assumes the reader can operate a Linux shell,
and several sites build directly on kernel mechanisms taught here:

- **[containers.bradpenney.io](https://containers.bradpenney.io)** — namespaces, cgroups, and
  capabilities taught here as general Linux kernel mechanisms are exactly what a container
  *is*, one layer up. This site explains the primitives; that one explains the container.
- **[k8s.bradpenney.io](https://k8s.bradpenney.io)** — every Kubernetes node is a Linux machine
  underneath, and `kubectl` itself runs from a Linux (or WSL) shell.
- **[python.bradpenney.io](https://python.bradpenney.io)** — the automation scripts taught there
  run on the Linux systems taught here.
- **[bradpenney.io](https://bradpenney.io)** — the hub all of these link out from.

The short version: this is where the terminal competence every other site assumes actually gets
built.

## Structure

The site uses a progressive learning structure:

- **Day One - Getting Started**: Two entry paths (SSH access or local setup) that converge into common orientation content
- **Level 1 - Everyday Navigation**: Essential commands (ls, cd, file management)
- **Level 2 - Finding & Filtering**: Searching and text processing (find, grep, pipes)
- **Level 3 - Processes & Permissions**: Process management, chmod, users/groups
- **Level 4 - System Management**: systemd, networking, storage
- **Level 5 - Under the Hood**: Boot process, kernel, /proc, namespaces
- **Level 6 - Special Topics**: Scripting, containers, automation

## Current Status: Editorial Review

This site is undergoing a quality review process to match the standards of [cs.bradpenney.io](https://cs.bradpenney.io) and [python.bradpenney.io](https://python.bradpenney.io).

**Process:**
- Articles are being reviewed one at a time
- Only vetted content appears in navigation
- Each article must meet quality standards before publication

See `CLAUDE.md` for complete style guidelines and quality standards.

## Development

### Prerequisites

- Python 3.11+
- Poetry for dependency management

### Setup

```bash
# Install dependencies
poetry install

# Serve locally (http://localhost:8000)
poetry run mkdocs serve

# Build static site
poetry run mkdocs build
```

### Contributing

See `CLAUDE.md` for comprehensive writing guidelines including:
- Tone and style requirements
- Command formatting standards
- Safety warning patterns
- Visual element usage (tabs, cards)
- Quality checklist

## Philosophy

This site teaches Linux with **production safety in mind**:

- **Real-world scenarios** you'll encounter on actual servers
- **Safety-first approach** — when commands are dangerous and why
- **Purpose-driven learning** — understanding the "why," not memorizing syntax
- **Progressive complexity** — from Day One orientation to system internals

## License

Content © Brad Penney. All rights reserved.
