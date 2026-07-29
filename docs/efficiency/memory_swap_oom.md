---
date: "2026-07-26 10:15"
title: "Swap and the OOM Killer: What Happens When Memory Runs Out"
description: "A process just vanished with no error, no stack trace, no core dump — just gone. dmesg has the answer: the kernel killed it on purpose. Here's swap, swappiness, and the OOM killer's actual decision process."
---

# Swap and the OOM Killer

!!! tip "Part of Efficiency"
    This article assumes [Namespaces and cgroups](namespaces_cgroups.md) — cgroups are what make a *container's* memory limit enforceable by the same mechanism this article covers system-wide. It's also a step in the [How Modern Software Really Runs on a CPU](https://bradpenney.io/pathways/cpu-to-cluster) pathway on [bradpenney.io](https://bradpenney.io).

A service just disappeared. No stack trace, no exception, no core dump. The process list simply doesn't have it anymore, and the application logs end mid-sentence. Before you assume a crash, run one command:

```bash title="Check for an OOM Kill"
dmesg -T | grep -i "killed process"
```

```text title="What You'll See"
[Fri Jul 24 03:12:07 2026] Out of memory: Killed process 18422 (java) total-vm:4812336kB, anon-rss:3980112kB, oom_score_adj:0
```

That's not a crash. That's the kernel, on purpose, deciding your process had to die so something else (often the kernel itself) could keep running.

``` mermaid
graph TD
    A["Memory pressure:\na process needs more RAM"] --> B{"Can page cache\nbe reclaimed cheaply?"}
    B -->|Yes| C["Drop clean cache pages\nno swap needed"]
    B -->|Not enough| D{"Is swap available\nand not yet full?"}
    D -->|Yes| E["Swap out anonymous pages\n(rate set by vm.swappiness)"]
    D -->|No| F["OOM killer:\npick a victim by oom_score"]
    E -->|Still not enough| F
    F --> G["Kill the process,\nreclaim its memory immediately"]

    style A fill:#2d3748,stroke:#cbd5e0,stroke-width:2px,color:#fff
    style B fill:#d69e2e,stroke:#cbd5e0,stroke-width:2px,color:#000
    style C fill:#68d391,stroke:#cbd5e0,stroke-width:2px,color:#000
    style D fill:#d69e2e,stroke:#cbd5e0,stroke-width:2px,color:#000
    style E fill:#63b3ed,stroke:#cbd5e0,stroke-width:2px,color:#000
    style F fill:#fc8181,stroke:#cbd5e0,stroke-width:2px,color:#000
    style G fill:#c53030,stroke:#cbd5e0,stroke-width:2px,color:#fff
```

## Where You Might Have Seen This

- **Windows' pagefile:** the same idea as Linux swap: overflow space on disk when physical RAM is exhausted, with the same fundamental trade (capacity for speed).
- **A server that gets sluggish long before `free -h` shows 0 available:** the kernel starts reclaiming and swapping *before* RAM is completely full, not at the last possible moment.
- **A container that restarts with no application error in its logs:** [`kubectl describe pod` showing `OOMKilled`](https://k8s.bradpenney.io/essentials/pod_failure_states/) is this exact mechanism, one layer up.
- **A database or JVM app tuned with `-Xmx` well below the host's total RAM:** a direct, deliberate hedge against the scenario this article describes.

## Swap: RAM's Overflow, Not Its Replacement

**[The Stack, the Heap, and Virtual Memory](https://cs.bradpenney.io/essentials/stack_heap_virtual_memory/)** covers how a process's memory is virtual: addresses the kernel maps to real physical RAM via page tables. **Swap** extends that mapping one step further: instead of every virtual page mapping to RAM, some pages can map to a reserved area of disk (a swap partition or swap file) instead. When a process touches a page that's currently swapped out, the kernel pauses it, reads that page back into RAM (evicting something else if needed), and resumes — invisibly, from the process's point of view, just much slower.

That "much slower" is the entire trade. Disk (even fast NVMe) is orders of magnitude slower than RAM for random access. Swap buys you the *appearance* of more memory than you physically have, at a real latency cost the moment it's actually used.

```bash title="Check Current Swap Usage"
free -h
```

```text title="Output"
               total        used        free      shared  buff/cache   available
Mem:            15Gi       9.2Gi       1.1Gi       412Mi       5.3Gi        5.9Gi
Swap:          2.0Gi       340Mi       1.7Gi
```

Two numbers matter more than they look like they should: **`available`** is what the kernel considers genuinely free for a new allocation right now, including memory it can reclaim from cache without swapping — a much more honest number than `free`, which counts only completely untouched RAM. **`buff/cache`** is the page cache: file data the kernel has opportunistically kept in RAM for speed, and will drop instantly if a process actually needs that memory. A server sitting at "1.1Gi free" with 5.3Gi in `buff/cache` isn't under memory pressure at all. That's the kernel using RAM efficiently, not RAM running out.

### `vm.swappiness`: How Eager the Kernel Is

`vm.swappiness` (0–100, default usually 60) tunes how aggressively the kernel prefers reclaiming page cache versus swapping out anonymous (process) memory when it needs to free RAM. Lower values favor keeping process memory in RAM and dropping cache first; higher values swap process memory out sooner to preserve cache.

```bash title="Check and Set swappiness"
cat /proc/sys/vm/swappiness      # (1)!
sudo sysctl vm.swappiness=10     # (2)!
```

1. Current value: 60 by default on most distributions.
2. Runtime change; persist it in `/etc/sysctl.conf` or a drop-in under `/etc/sysctl.d/` to survive reboot.

Database and latency-sensitive servers commonly run with `swappiness` near 0 or 1 — accepting more aggressive cache eviction in exchange for near-guaranteeing their working set never gets swapped to disk mid-query.

## The OOM Killer: When There's Nowhere Left to Put It

Swap has a limit too. When physical RAM *and* configured swap are both exhausted, or swap is disabled entirely (as it commonly is on servers and inside containers), the kernel faces a request it genuinely cannot satisfy. Its answer is the **OOM (out-of-memory) killer**: pick a process, kill it immediately, and reclaim its memory, rather than let the whole system lock up trying to satisfy an impossible allocation.

The kernel doesn't kill at random. Every process has an **`oom_score`**, recalculated dynamically, weighted heavily toward how much memory the process is actually using: a process consuming 4GB is a far more attractive target than one using 40MB, all else equal. You can read it directly:

```bash title="Check a Process's OOM Score"
cat /proc/<pid>/oom_score
```

You can also *influence* it, without changing how much memory the process actually uses:

```bash title="Adjust OOM Killer Priority"
echo -1000 > /proc/<pid>/oom_score_adj   # (1)!
echo 1000 > /proc/<other_pid>/oom_score_adj  # (2)!
```

1. Effectively exempt this process from being chosen: `-1000` disables it as an OOM target entirely.
2. Make this process the preferred target: Kubernetes uses exactly this mechanism, setting `oom_score_adj` based on a Pod's QoS class, so lower-priority workloads are sacrificed before higher-priority ones on a memory-pressured node.

## Why This Matters for Platform Work

- **A silently-vanished process with no application-level error is an OOM kill until proven otherwise.** `dmesg -T | grep -i "killed process"` is the first command, before digging through application logs that will never mention it. The process didn't get a chance to log anything on the way out.
- **"Free memory" as reported by naive tools is frequently the wrong number to alert on.** Paging in the `available` column of `free -h`, or the equivalent in your monitoring stack, avoids false-positive memory-pressure alerts triggered by a healthy, well-utilized page cache.
- **Disabling swap entirely (common in container hosts and some Kubernetes node configurations) removes a shock absorber, not just a slowdown.** Without swap, a memory spike goes straight from "fine" to "OOM kill" with no graceful degradation in between — a deliberate trade for predictable latency, but one worth knowing you made.
- **`oom_score_adj` is the exact mechanism behind Kubernetes QoS-based eviction ordering:** a `BestEffort` Pod is set up to die first on a memory-pressured node, a `Guaranteed` Pod last, by adjusting this same kernel value the moment the Pod starts. **[Resource Requests and Limits](https://k8s.bradpenney.io/essentials/resource_requests_limits/)** picks up that thread directly.

## Common Scenarios

=== "Diagnosing a Mystery Restart"

    A process keeps restarting with no application error. Check for an OOM kill first, before assuming an application bug:

    ```bash title="OOM Kill Investigation"
    dmesg -T | grep -i "killed process"
    journalctl -k | grep -i "out of memory"  # (1)!
    ```

    1. `journalctl -k` shows kernel-ring-buffer messages that survive a reboot, unlike `dmesg` alone.

=== "Protecting a Critical Process"

    A monitoring agent or SSH daemon should be the last thing killed under memory pressure, even though it isn't using much memory to begin with:

    ```bash title="Exempt a Critical Process"
    echo -1000 > /proc/$(pgrep sshd)/oom_score_adj
    ```

=== "Sizing Swap on a New Server"

    A common, defensible starting point for a general-purpose server: swap equal to RAM up to 8GB, then a flat 4–8GB beyond that — enough to absorb a transient spike without masking a real memory leak for hours. Database and latency-critical hosts often go smaller, or to zero, deliberately trading that shock absorber for predictable performance.

## Practice Exercises

??? question "Exercise 1: Reading an OOM Kill Message"

    In the `dmesg` output from the top of this article, what does `anon-rss:3980112kB` tell you, and why does it matter more than `total-vm`?

    ??? tip "Solution"
        `anon-rss` (anonymous resident set size) is memory the process is *actually using right now* in physical RAM — roughly 3.9GB here. `total-vm` (4.8GB) is the process's total virtual address space, which routinely includes memory that's reserved but never touched, shared libraries counted per-process, and other bookkeeping that vastly overstates real usage. The OOM killer's scoring is based on real consumption (`anon-rss` and similar), which is why `total-vm` alone is a misleading number to alert or reason about.

??? question "Exercise 2: swappiness Trade-off"

    A teammate sets `vm.swappiness=0` on every server "to make things faster," reasoning that swapping is always slow. What's the risk?

    ??? tip "Solution"
        `swappiness=0` doesn't eliminate swapping in modern kernels. It strongly deprioritizes it in favor of reclaiming page cache first, right up until cache reclaim genuinely can't free enough memory, at which point the kernel swaps or OOM-kills anyway. The real risk is aggressive cache eviction under memory pressure: a server that was relying on a large, warm page cache for fast file/database reads can see that cache thrashed away first, hurting I/O-heavy workloads specifically to protect anonymous memory that may not have needed protecting. The right setting depends on the workload, not a blanket "swapping is bad" rule.

## Quick Recap

- Swap extends virtual memory onto disk, at a real latency cost. It's a shock absorber, not a substitute for RAM.
- `free -h`'s `available` column, not `free`, is the honest measure of how much memory is genuinely up for grabs.
- The OOM killer activates when RAM and swap are both exhausted, choosing a victim by `oom_score`, weighted heavily by memory consumption.
- `oom_score_adj` lets you protect or sacrifice specific processes ahead of time: the same mechanism Kubernetes uses for QoS-based eviction ordering.
- A silently-vanished process with no application error is `dmesg -T | grep -i "killed process"` territory before anything else.

## What's Next

Swap and the OOM killer are host-wide versions of a story that gets scoped down and reused constantly: a memory ceiling, and what happens when something hits it. The same enforcement mechanism, applied to one cgroup instead of the whole machine, is what makes a container's memory limit real.

If you're following the [How Modern Software Really Runs on a CPU](https://bradpenney.io/pathways/cpu-to-cluster) pathway on [bradpenney.io](https://bradpenney.io), the next step is **[What Is a Container, Really?](https://containers.bradpenney.io/day_one/what_is_a_container/)**, where namespaces and cgroups stop being abstract kernel mechanisms and become the thing Docker and Podman are actually built from.

---

## Further Reading

### Command References

- `man free`: the tool for reading current memory and swap state.
- `man dmesg` / `man journalctl`: where OOM kill events are logged.
- `man 5 proc`: documents `/proc/<pid>/oom_score` and `oom_score_adj`.

### Deep Dives

- **[Namespaces and cgroups](namespaces_cgroups.md):** how a *container's* memory limit gets enforced by this same kernel mechanism, scoped to one cgroup instead of the whole system.
- **[The Stack, the Heap, and Virtual Memory](https://cs.bradpenney.io/essentials/stack_heap_virtual_memory/):** the virtual-to-physical memory mapping that swap extends onto disk.

### Official Documentation

- [Linux kernel documentation: `vm.swappiness`](https://docs.kernel.org/admin-guide/sysctl/vm.html#swappiness): the full, authoritative tuning reference.
