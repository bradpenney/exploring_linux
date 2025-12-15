# Viewing Processes: ps, top, and htop

!!! quote "Who's doing what on your system?"

## What is a Process?

You've launched a web browser, started a script, or have a web server running in the background. Each of these running instances of a program is a **process**.

Your Linux system is juggling hundreds or even thousands of these processes at once, from essential system services to the commands you type. Being able to see what's running is a fundamental skill for troubleshooting, monitoring, and managing your system.

Three commands are the workhorses for viewing processes:
-   **`ps`**: Takes a static **snapshot** of the currently running processes.
-   **`top`**: Provides a **live dashboard** of your system's state and running processes.
-   **`htop`**: An **interactive, user-friendly** version of `top`.

Let's see how and when to use each.

## `ps`: The Snapshot

The `ps` (process status) command gives you a list of processes running *at the moment you run the command*. It doesn't update.

`ps` has many options and two different syntax styles (BSD and System V), which can be confusing. For now, just memorize these two common recipes.

### `ps aux` (BSD Syntax)

This is the most common and useful combination.
-   `a`: Show processes for all users.
-   `u`: Display user-oriented format (shows user, CPU/memory usage, etc.).
-   `x`: Show processes not attached to a terminal (background services).

```bash
ps aux
```

**Output (abbreviated):**
```
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.0  0.1 169836 13284 ?        Ss   Dec14   0:00 /sbin/init
root           2  0.0  0.0      0     0 ?        S    Dec14   0:00 [kthreadd]
www-data     859  0.1  0.5 815592 45864 ?        Sl   10:30   0:02 nginx: worker process
brad        1234  0.5  2.1 123456 168920 ?       Sl   10:35   0:15 /usr/bin/code
brad        5678  0.0  0.1  23020  8084 pts/0    Ss   11:00   0:00 -bash
brad        5690  0.0  0.0  30092  3748 pts/0    R+   11:02   0:00 ps aux
```

**Key Columns:**
-   `USER`: The user that owns the process.
-   `PID`: **Process ID**. A unique number for each process. You'll use this a lot.
-   `%CPU`: Percentage of CPU time the process is using.
-   `%MEM`: Percentage of RAM the process is using.
-   `START`: The time the process started.
-   `TIME`: Total CPU time the process has used.
-   `COMMAND`: The command that started the process.

### Finding a Specific Process

The output of `ps aux` is long. You almost always pipe it to `grep`.

```bash title="Find the nginx process"
ps aux | grep "nginx"
```

**Output:**
```
root         858  0.0  0.1 815304  9348 ?        Ss   10:30   0:00 nginx: master process /usr/sbin/nginx
www-data     859  0.1  0.5 815592 45864 ?        Sl   10:30   0:02 nginx: worker process
brad        5710  0.0  0.0  14852  1088 pts/0    S+   11:05   0:00 grep --color=auto nginx
```
Notice the `grep` command itself appears in the list!

### `ps -ef` (System V Syntax)

This is another common way to see all processes. It gives slightly different information, like the Parent PID (`PPID`).

```bash
ps -ef
```

**Output (abbreviated):**
```
UID          PID    PPID  C STIME TTY          TIME CMD
root           1       0  0 Dec14 ?        00:00:00 /sbin/init
root           2       0  0 Dec14 ?        00:00:00 [kthreadd]
root         858       1  0 10:30 ?        00:00:00 nginx: master process /usr/sbin/nginx
www-data     859     858  0 10:30 ?        00:00:02 nginx: worker process
```

- `UID`: User ID.
- `PID`: Process ID.
- `PPID`: **Parent Process ID**. The PID of the process that started this one.

## `top`: The Live Dashboard

`top` provides a real-time, continuously updating view of your system. It's like Task Manager on Windows.

```bash
top
```

The screen is split into two parts:
1.  **The Summary:** The first few lines show system-wide stats (load, memory, CPU).
2.  **The Process List:** The table below shows individual processes, sorted by `%CPU` by default.

**Key Interactive Commands (while `top` is running):**
-   `q`: **Quit** `top`.
-   `M`: Sort processes by **Memory** usage.
-   `P`: Sort processes by **CPU** usage (the default).
-   `k`: **Kill** a process. It will prompt you for the PID to kill.
-   `u`: Show processes for a specific **user**.
-   `h`: Show the **help** screen.

`top` is on every Linux system, making it a reliable tool for a quick live check.

## `htop`: The Interactive Powerhouse

`htop` is a modern, user-friendly replacement for `top`. It's not always installed by default, but it's worth adding.

```bash
sudo apt install htop
htop
```

**Why `htop` is better:**
-   **Color-coded display:** Easier to read at a glance.
-   **Full command visible:** No more truncated command names.
-   **Easy scrolling:** Use arrow keys and Page Up/Down to move through the process list.
-   **Mouse support:** You can click on processes and headers.
-   **Intuitive keys:** Function keys for common actions (like `F9` for Kill) are shown at the bottom.

## When to Use Which?

| Command | Use When You Need To... |
|:---|:---|
| **`ps`** | ...get a specific piece of information right now (e.g., a PID) for use in a script. |
| **`top`** | ...get a quick, real-time overview on any system, without installing new tools. |
| **`htop`** | ...interactively explore running processes, sort them in different ways, and easily manage them. |

My workflow:
-   I use `ps aux | grep ...` constantly in scripts or to quickly find a PID.
-   If I'm on a new server, I'll use `top` for a first look.
-   If I'm doing any serious process debugging, I install and use `htop` immediately.

## Practical Examples

### Find a Process's PID

You need to restart a frozen script called `my_app.py`.
```bash
ps aux | grep "my_app.py"
# brad   4321  0.5  0.2 ... python my_app.py
```
The PID is `4321`.

### Check if a Service is Running

```bash
ps aux | grep "sshd"
```
If you see a process for `sshd`, the SSH server is running.

### Find What's Using All Your CPU

Run `htop` and press `P` to sort by CPU. The processes at the top are your culprits.

### Find What's Using All Your Memory

Run `htop` and press `M` to sort by memory.

## Practice Exercises

**Exercise 1: Find your shell**
Find the Process ID (PID) of your own shell (e.g., `bash` or `zsh`).
```bash
ps aux | grep "bash"
```
*(Remember to ignore the `grep` command itself in the output!)*

**Exercise 2: Explore with `top`**
Run `top`. Press `M` to sort by memory. What's using the most memory? Press `P` to switch back to CPU. Press `q` to quit.

**Exercise 3: Install and use `htop`**
If you don't have it, install `htop` (`sudo apt install htop`). Run it. Use the arrow keys to scroll. Press `F9` (Kill), then press `Esc` to cancel without killing anything. Press `F10` or `q` to quit.

## Key Takeaways
-   **`ps`** gives a static **snapshot** of processes.
-   **`top`** provides a **live dashboard** of system activity.
-   **`htop`** is an **interactive, user-friendly** version of `top`.
-   Use `ps aux | grep ...` to find specific processes and their **PIDs**.
-   Use `top` or `htop` to see which processes are consuming the most **CPU** or **Memory**.

Being able to see what's running on your system is the first step to managing it. These tools are your windows into the inner workings of your Linux machine.
