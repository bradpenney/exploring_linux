# Managing Processes: kill, jobs, bg, fg, and nice

!!! quote "Taking control of what's running on your system"

## From Viewing to Controlling

You know how to see what's running with `ps`, `top`, and `htop`. But what happens when a process is frozen, using too much CPU, or you need to run a long task without tying up your terminal?

This is where process management comes in. You need to be able to stop processes, pause them, run them in the background, and manage their priority. This guide covers the essential commands for taking control.

## Sending Signals with `kill`

Despite its aggressive name, `kill` doesn't just kill processes; it sends **signals** to them. A signal is a message sent to a process, telling it to do something.

The basic syntax is `kill [PID]`, where PID is the Process ID you get from `ps` or `htop`.

### The Three Most Common Signals

While there are many signals, you'll use these three 99% of the time.

#### `SIGTERM` (15): The Polite Request

-   **Signal Number:** 15
-   **What it does:** Asks the process to shut down gracefully. This gives the process a chance to save its work, close files, and exit cleanly.
-   **How to send:** This is the default signal.

```bash title="Politely ask a process to terminate"
kill 1234
```
(Where 1234 is the PID).

#### `SIGKILL` (9): The Forceful Takedown

-   **Signal Number:** 9
-   **What it does:** Kills the process immediately, no questions asked. The process has no chance to clean up. This is the "I'm not asking, I'm telling" signal.
-   **How to send:**

```bash title="Forcefully kill a process"
kill -9 1234
# or
kill -KILL 1234
```

!!! warning "When to Use `kill -9`"
    Only use `SIGKILL` when a process is completely frozen and won't respond to a normal `kill` command. Forcefully killing a process can lead to corrupted files or a messy system state. Always try a polite `SIGTERM` first.

#### `SIGHUP` (1): The "Hang Up"

-   **Signal Number:** 1
-   **What it does:** Historically, this meant the controlling terminal "hung up". Today, it's commonly used to tell a service to **reload its configuration file** without restarting.
-   **How to send:**

```bash title="Tell nginx to reload its config"
# First, find the master process PID
ps aux | grep "nginx: master"
# root   858 ... nginx: master process ...

# Send the SIGHUP signal
sudo kill -1 858
```
This is much better than restarting the whole service.

### Killing by Name: `pkill` and `killall`

Remembering PIDs is a pain. `pkill` and `killall` let you kill processes by name.

```bash title="Kill a process by its name"
pkill firefox
```
This finds any process with "firefox" in its name and sends `SIGTERM` to it.

```bash title="Forcefully kill all processes named 'my_script.py'"
killall -9 my_script.py
```

**`pkill` vs `killall`:**
-   `pkill`: Matches against the full command string (more flexible).
-   `killall`: Matches against the exact process name (more precise).

Use `pkill` more often, but be specific to avoid killing the wrong process.

## Job Control: `&`, `jobs`, `bg`, `fg`

Sometimes you need to run a command that takes a long time, but you want to keep using your terminal. This is called **job control**.

### `&`: Run in the Background

To start a command in the background, add an ampersand (`&`) to the end.

```bash title="Start a long-running script in the background"
./my_long_script.sh &
```
The shell will print the job ID and PID, and immediately return you to the command prompt.

### `Ctrl+Z`: Suspend a Foreground Process

If you start a command in the foreground and realize it's going to take a while, you can suspend it.

```bash
./my_long_script.sh
# (realizing this is taking too long...)
[Press Ctrl+Z]

[1]+  Stopped                 ./my_long_script.sh
```
The process is now paused.

### `jobs`: List Background/Suspended Jobs

The `jobs` command shows you all the jobs associated with your current terminal session.

```bash
jobs -l
# [1]+  12345 Stopped                 ./my_long_script.sh
```
-   `[1]`: The job ID.
-   `12345`: The PID.
-   `Stopped`: The status.

### `bg`: Resume in the Background

To resume a stopped job *in the background*, use `bg`.

```bash
bg %1
```
The `%1` refers to job ID 1. The job will now run in the background.

### `fg`: Resume in the Foreground

To bring a background or suspended job back to the foreground, use `fg`.

```bash
fg %1
```
The job is now running in your terminal again, and you won't get your prompt back until it finishes.

## Managing Priority: `nice` and `renice`

On a multi-user system, not all processes are equally important. The "niceness" of a process tells the kernel how to prioritize it.

-   **Niceness Range:** -20 (highest priority) to 19 (lowest priority).
-   **Default:** Processes start with a niceness of 0.
-   **Lower number = higher priority.** A process with a niceness of -10 is "less nice" and gets more CPU time than a process with a niceness of 10.

### `nice`: Start a Process with a Different Priority

Use `nice` to launch a command with a non-default niceness.

```bash title="Run a backup with low priority"
nice -n 10 ./backup_script.sh
```
This starts the script with a niceness of 10, so it won't bog down the system.

### `renice`: Change a Running Process's Priority

To change the priority of a process that's already running, use `renice`.

```bash title="Make a running process less important"
# Find the PID of the CPU-hungry process
ps aux | grep "video_encoder"
# brad   5555  95.0 ...

# Lower its priority (make it 'nicer')
renice 15 5555
```

!!! tip "Only `root` can increase priority"
    Any user can make their processes *nicer* (increase the niceness value, lowering priority). Only the `root` user can make a process *less nice* (decrease the niceness value, increasing priority).

## Practical Scenarios

### A GUI Application Freezes

You're running a GUI app from the terminal and it freezes.
1.  Switch to another terminal.
2.  `ps aux | grep "frozen_app_name"` to find the PID.
3.  `kill [PID]`
4.  If it's still there after a few seconds, `kill -9 [PID]`.

### Running a Long-Running Task

You need to run a data processing script that will take an hour.
```bash
./process_data.sh &
```
The script runs in the background. You can check on it with `jobs` or `ps`, and you can log out and it will keep running (if you use `nohup` or `screen`/`tmux`).

### Reducing the Impact of a Heavy Task

You're compiling code, and it's making your desktop laggy.
1.  Find the PID of the compiler (e.g., `gcc`).
2.  `renice 10 [PID]` to make it a lower priority. The system will feel more responsive.

## Practice Exercises

**Exercise 1: Kill a process**
1.  Run a command that takes a while, like `sleep 300`.
2.  Open another terminal.
3.  Find the PID of the `sleep` command using `ps aux | grep "sleep"`.
4.  Use `kill` to terminate it. Check `ps` again to confirm it's gone.

**Exercise 2: Job Control**
1.  Run `sleep 300` again.
2.  Press `Ctrl+Z` to suspend it.
3.  Run `jobs` to see the stopped job.
4.  Run `bg %1` to resume it in the background. Check `jobs` again to see its status is now "Running".
5.  Run `fg %1` to bring it back to the foreground.
6.  Press `Ctrl+C` to finally terminate it.

## Key Takeaways
-   **Signals** are messages sent to processes.
-   **`kill [PID]`** sends `SIGTERM` (15), a polite request to stop.
-   **`kill -9 [PID]`** sends `SIGKILL` (9), a forceful termination.
-   **`pkill [name]`** and **`killall [name]`** are useful for killing by name.
-   **`&`** at the end of a command starts it in the background.
-   **`Ctrl+Z`** suspends a foreground job.
-   **`jobs`, `bg`, `fg`** are used to manage background and suspended jobs.
-   **`nice`** and **`renice`** control process priority to manage system load.

Mastering these commands gives you fine-grained control over your system's resources and running applications. You can ensure important processes get the CPU time they need, while long-running, non-critical tasks stay out of the way.
