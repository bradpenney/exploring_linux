---
date: "2026-07-14 09:00"
title: "Namespaces and cgroups: How Linux Isolates a Process"
description: "What the kernel uses to decide what a process can see and how much it can consume — namespaces for visibility, cgroups for limits, the primitives behind every container."
---

# Namespaces and cgroups

!!! tip "Part of Efficiency"
    This article goes one layer beneath [Processes](../essentials/processes.md). There you learned how to list and control running programs. Here you learn what the kernel uses to decide what each of those programs is allowed to *see* and *use*: the same two mechanisms that, stacked together, make a container a container.

Put two processes on the same machine. The first runs `ps aux` and sees every other process on the box, every mounted filesystem, every network interface. The second runs the same command and sees four processes, one filesystem, and a network stack with a single interface it doesn't recognise. Same kernel, same hardware, no virtual machine anywhere.

The difference is two kernel features most people use every day without ever naming: **namespaces** and **cgroups**. Almost everyone meets them second-hand, through Docker or Podman or systemd, and never learns what they actually are. That secondhand knowledge is where fuzzy mental models come from. "A container is a lightweight VM" is the classic one, and it's wrong precisely because it skips these two primitives.

Isolation on Linux splits into two independent questions, and the kernel answers them with two different mechanisms:

- **What can this process see?** — answered by namespaces.
- **How much can this process consume?** — answered by cgroups.

They are genuinely separate. A process can be in its own namespace with no resource limits, or capped by a cgroup while sharing the host's full view of the system. Most of the confusion around "how does isolation work" clears up the moment you stop treating them as one thing. We'll walk each in turn, then see what happens when you combine them.

---

## Where You've Seen This

If you've ever run `docker run -m 512m` or set a memory limit on a Kubernetes Pod, you've configured a cgroup without knowing its name; if you've watched a container show its own hostname and private process list, you've watched namespaces at work. This article is the Linux machinery underneath those tools — the same primitives, without the wrapper.

---

## Namespaces: Controlling What a Process Can See

A namespace is a wrapper around a global system resource that makes the processes inside it believe they have their own private copy. The processes still run on the same kernel. They just get shown a curated view of the world.

Linux has eight namespace types, each covering one category of "what you can see":

| Namespace | What it isolates | The illusion it creates |
|-----------|------------------|-------------------------|
| **mount** (`mnt`) | The set of mounted filesystems | Its own root filesystem and mount table |
| **PID** | Process IDs | Its own PID 1 and process tree |
| **network** (`net`) | Interfaces, routes, firewall rules, ports | Its own network stack |
| **UTS** | Hostname and domain name | Its own hostname |
| **IPC** | Shared memory, semaphores, message queues | Its own IPC objects |
| **user** | User and group ID mappings | Root inside, unprivileged outside |
| **cgroup** | The cgroup hierarchy root | Its own view of the resource tree |
| **time** | The boot and monotonic clocks | Its own uptime offset |

Every process is in a namespace of each type. On a normal system they're all in the *same* namespaces, the host's, which is why everything can see everything. Create a new namespace and move a process into it, and that process's view narrows to whatever that namespace contains.

### Seeing the namespaces a process is in

Each process exposes its namespace membership under `/proc`:

``` bash title="A Process's Namespace Membership"
ls -l /proc/self/ns/    # (1)!
```

1. Output: one symlink per namespace type, each pointing at an inode like `net:[4026531840]`. Two processes with the *same* inode number share that namespace; different numbers mean they're isolated from each other on that axis.

The `lsns` command reads the same information for the whole system and groups it:

``` bash title="List Every Network Namespace"
lsns --type net    # (1)!
```

1. Lists every network namespace, its inode, how many processes are in it, and the command that owns it. On a plain server you'll see one. On a host running containers you'll see one per container.

### Creating one yourself

You don't need any container tooling to make a namespace; `unshare` does it directly. This creates a new PID and mount namespace, then starts a shell inside them:

``` bash title="Enter a New PID + Mount Namespace"
sudo unshare --pid --fork --mount-proc bash    # (1)!
```

1. `--pid` gives a new PID namespace, `--fork` runs the shell as a child inside it (the namespace needs a PID 1), and `--mount-proc` remounts `/proc` so `ps` reflects the new view rather than the host's.

Inside that shell, run `ps aux`:

``` bash title="Inside the New Namespace"
ps aux    # (1)!
```

1. You'll see two processes: `bash` as **PID 1** and the `ps` command itself. The hundreds of processes running on the host are still there; this shell simply can't see them, because a PID namespace only shows processes created within it.

That is the whole trick. Nothing was virtualised, nothing was copied. The kernel is scheduling the same processes on the same CPUs; it's just showing this shell a filtered process table. Exit the shell and the namespace is torn down, because the last process in it is gone.

### The user namespace earns a special mention

Most namespaces hide things. The **user namespace** does something more interesting: it *remaps* identity. A process can be UID 0, root, inside its user namespace while mapping to an ordinary unprivileged UID on the host. Root inside, nobody in particular outside.

This is the single most important namespace for security, and it's the foundation of rootless containers. A process that believes it's root, can act like root against its own isolated resources, but holds no real privilege on the host, has a dramatically smaller blast radius if it's compromised. The privilege half of that story (what "acting like root" is actually made of) is [Linux capabilities](capabilities.md), which we cover next.

---

## cgroups: Controlling What a Process Can Consume

Namespaces answer "what can you see." They say nothing about "how much can you take." A process alone in every namespace can still consume all the CPU and every byte of RAM on the machine, starving everything else. That's the job of the second mechanism.

**Control groups**, or cgroups, organise processes into a hierarchy and enforce resource limits on each group. Where a namespace hides resources, a cgroup meters them. The two are orthogonal, which is exactly why they're separate features.

Modern systems use **cgroup v2**, a single unified hierarchy mounted at `/sys/fs/cgroup`. It's a real filesystem: directories are groups, and the files inside them are the knobs and gauges.

``` bash title="Available cgroup Controllers"
cat /sys/fs/cgroup/cgroup.controllers    # (1)!
```

1. Output: the available controllers, typically `cpu io memory pids` and a few more. Each controller governs one class of resource.

The controllers you'll reach for most:

- **memory** — cap total memory with `memory.max`; the group is OOM-killed if it exceeds a hard limit.
- **cpu** — set a ceiling with `cpu.max` (a quota-per-period pair) or a relative share with `cpu.weight`.
- **pids** — cap the number of processes with `pids.max`, which stops a fork bomb from taking down the host.
- **io** — throttle block-device bandwidth per group.

### systemd is already doing this

You almost never edit `/sys/fs/cgroup` by hand, because on any modern distribution **systemd is the cgroup manager**. Every service systemd starts gets its own cgroup automatically. This is why cgroups and services are so tightly linked — managing one is managing the other.

``` bash title="Inspect systemd's cgroup Tree"
systemctl status sshd    # (1)!
systemd-cgls             # (2)!
systemd-cgtop            # (3)!
```

1. Look for the `CGroup:` line in the output; it names the exact cgroup path this service's processes live in.
2. Prints the full cgroup tree as a hierarchy, so you can see how systemd has grouped every service and user session.
3. Live resource usage per cgroup, like `top` but grouped by service rather than by process.

Setting a limit on a service is a one-liner, and systemd writes the cgroup file for you:

``` bash title="Cap a Service's Memory"
sudo systemctl set-property sshd.service MemoryMax=512M    # (1)!
```

1. From now on the `sshd` service and everything it spawns are capped at 512&nbsp;MB. Exceed it and the group is reclaimed or OOM-killed, but the rest of the system stays healthy. The equivalent by hand would be writing `536870912` into that group's `memory.max`.

### Watching a limit bite

You can prove the limit is real without any special tooling. Run a deliberately hungry command inside a temporary scope with a tight memory cap:

``` bash title="Enforce a Memory Cap on a One-Off Command"
sudo systemd-run --scope -p MemoryMax=50M \
  bash -c 'a=(); while true; do a+=($(seq 1 100000)); done'    # (1)!
```

1. The shell tries to grow an array without bound. Instead of consuming all system memory and dragging the whole box into swap, it hits the 50&nbsp;MB ceiling and is OOM-killed, and *only* it is killed. That containment is the entire value proposition: one misbehaving workload can't take the others down with it.

---

## Putting Them Together

Now the two questions have two answers, and they compose cleanly:

``` mermaid
graph TD
    P["A process"]
    NS["Namespaces\nwhat it can see"]
    CG["cgroups\nhow much it can use"]
    CAP["Capabilities\nwhat it's allowed to do"]

    P --> NS
    P --> CG
    P --> CAP

    NS --> V["Own PID tree, filesystem,\nnetwork, hostname"]
    CG --> R["Capped CPU, memory,\nprocess count, I/O"]
    CAP --> A["Least privilege,\nnot all-or-nothing root"]
```

Take an ordinary process. Give it its own namespaces so it sees a private filesystem, process tree, and network. Put it in a cgroup so it can't starve its neighbours. Strip it down to only the privileges it genuinely needs. What you've just described, feature by feature, is a **container**. There is no additional "container" object in the kernel — the word is shorthand for a process wearing this specific combination of namespaces, cgroups, and capabilities. Docker and Podman are automation that sets all of this up in one command; the isolation itself is pure Linux, exactly what you exercised by hand above. [Exploring Containers](https://containers.bradpenney.io) picks up from exactly this point — [What Is a Container, Really?](https://containers.bradpenney.io/day_one/what_is_a_container/) covers the same idea from the container-tooling side, without repeating the kernel mechanics you just did by hand here.

Seeing it this way retires a few persistent myths. A container is not a lightweight VM: there's no second kernel, no emulated hardware, just a filtered view and a resource cap. "It works on my machine but not in the container" is almost always a namespace difference (a different mount view, a different network stack), not sorcery. And a container that "ate all the RAM" was a container whose cgroup limits were never set.

---

## Common Pitfalls

!!! warning "Where isolation surprises people"
    - **A PID namespace needs a PID 1.** If the process you run as PID 1 doesn't reap its children, zombie processes pile up inside the namespace. This is why container images often need a lightweight init.
    - **cgroup v1 and v2 are different worlds.** Older material describes v1's multiple separate hierarchies. Almost everything current is v2's single unified hierarchy. Check with `stat -fc %T /sys/fs/cgroup` — `cgroup2fs` means v2.
    - **Namespaces don't imply limits.** A process can be fully namespace-isolated and still consume the whole machine. Visibility and consumption are separate; you need cgroups for the second.
    - **Editing `/sys/fs/cgroup` by hand fights systemd.** systemd owns the hierarchy on modern systems. Use `systemctl set-property` or a drop-in unit so your changes survive and don't get reverted.

---

## Quick Reference

| Task | Command |
|------|---------|
| List a process's namespaces | `ls -l /proc/<pid>/ns/` |
| List all namespaces of a type | `lsns --type net` |
| Enter a new PID + mount namespace | `sudo unshare --pid --fork --mount-proc bash` |
| Show available cgroup controllers | `cat /sys/fs/cgroup/cgroup.controllers` |
| View the cgroup tree | `systemd-cgls` |
| Live per-cgroup resource usage | `systemd-cgtop` |
| Cap a service's memory | `systemctl set-property NAME.service MemoryMax=512M` |
| Run a one-off command in a capped scope | `systemd-run --scope -p MemoryMax=50M CMD` |
| Check cgroup version | `stat -fc %T /sys/fs/cgroup` |

---

## Practice Exercises

??? question "Exercise 1: Watch a PID namespace lie to you"
    Enter a new PID namespace, note the PID your shell reports, then find that same shell's real PID from the host. What accounts for the two different numbers?

    ??? tip "Solution"
        ``` bash title="Compare the Two Views"
        sudo unshare --pid --fork --mount-proc bash    # (1)!
        ps aux                                          # (2)!
        # (from another terminal, on the host)
        ps aux | grep bash                              # (3)!
        ```

        1. Start a shell in a fresh PID namespace.
        2. Inside it, your shell is **PID 1** and the table is nearly empty.
        3. On the host, the same shell has an ordinary high PID among hundreds of others.

        **Explanation:** It's one process, shown through two namespaces. A PID namespace only displays processes created within it, so inside it your shell is the first (and nearly only) process; the host sees the full table it's really part of.

??? question "Exercise 2: Prove a cgroup limit is enforced"
    Run a memory-hungry command inside a scope capped at 50&nbsp;MB while watching per-cgroup usage in another terminal. Confirm that only that scope is affected when it hits the ceiling.

    ??? tip "Solution"
        ``` bash title="Cap and Observe"
        sudo systemd-run --scope -p MemoryMax=50M \
          bash -c 'a=(); while true; do a+=($(seq 1 100000)); done'    # (1)!
        systemd-cgtop                                                   # (2)!
        ```

        1. Runs the memory-eater inside a 50&nbsp;MB scope.
        2. In a second terminal, watch usage climb to the cap and get reclaimed.

        **Explanation:** The scope's usage rises to roughly 50&nbsp;MB and the process is OOM-killed, while every other cgroup is untouched. The limit contained the damage to exactly one group.

---

## What's Next

You've covered two of the three isolation primitives: what a process can **see** (namespaces) and how much it can **use** (cgroups). The third is what a process is **allowed to do**: the difference between a container that runs as harmless "root" and one that can compromise the host. Head to **[Linux Capabilities: Breaking Up Root](capabilities.md)** to learn how the kernel splits the single all-powerful root account into around forty independent privileges you can grant one at a time.

---

## Further Reading

### Command References

- `man 7 namespaces` — the authoritative overview of all namespace types
- `man 1 unshare` and `man 1 lsns` — creating and inspecting namespaces
- `man 5 systemd.resource-control` — every cgroup property systemd exposes (`MemoryMax`, `CPUQuota`, `TasksMax`, and more)

### Deep Dives

- [Processes](../essentials/processes.md) — the PID, parent/child tree, and signals these namespaces isolate
- [Linux Capabilities: Breaking Up Root](capabilities.md) — the privilege dimension of process isolation

### Official Documentation

- [The Linux Kernel: cgroup v2](https://docs.kernel.org/admin-guide/cgroup-v2.html) — the definitive reference for the unified hierarchy and every controller
- [man7.org: namespaces(7)](https://man7.org/linux/man-pages/man7/namespaces.7.html) — Michael Kerrisk's canonical namespace documentation
