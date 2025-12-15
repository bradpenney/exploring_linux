# Reading System Logs with journalctl

!!! quote "The structured, modern way to find out what happened"

## Beyond Plain Text Logs

For decades, Linux logs were simple text files in `/var/log`. You'd use `grep`, `tail`, and `less` to parse them. This works, but it can be clunky.

Modern Linux systems using `systemd` have a powerful, centralized logging solution: the **journal**. All system and service logs are collected in a structured binary format, and the `journalctl` command is your tool to query it.

**Why `journalctl` is a superpower:**
-   **Structured Data:** Logs aren't just text; they have metadata like the service name, PID, and priority.
-   **Centralized:** One place for all system, service, and kernel logs.
-   **Powerful Filtering:** You can slice and dice logs by service, time, priority, and more with simple commands.

## Basic Log Viewing

### Viewing All Logs

Running `journalctl` by itself shows you everything, starting with the oldest logs.

```bash
journalctl
```
This is often too much information. You'll almost always use filters.

### Viewing Recent Logs

More useful is looking at the most recent logs.

```bash title="Show the last 20 log entries"
journalctl -n 20
```

### Following Logs in Real-Time

This is the `journalctl` equivalent of `tail -f`. It shows you a live stream of all logs as they happen.

```bash title="Follow all system logs live"
journalctl -f
```
Press `Ctrl+C` to stop.

## Filtering by Unit (Service)

This is the killer feature of `journalctl`. You can instantly pull up all logs for a specific service.

```bash title="Show all logs for the nginx service"
journalctl -u nginx.service
```
No more hunting for the right log file in `/var/log`!

You can also view logs for multiple services at once, interleaved chronologically.
```bash title="Show logs from nginx and mysql"
journalctl -u nginx -u mysql
```

## Filtering by Time (`--since` and `--until`)

This is another incredibly powerful feature.

### Relative Time

```bash title="Show logs from the last hour"
journalctl --since "1 hour ago"
```

```bash title="Show logs from today"
journalctl --since today
```

### Absolute Time

```bash title="Show logs from a specific date and time"
journalctl --since "2024-12-14 14:00:00"
```

### Time Range

```bash title="Show logs from a specific time window"
journalctl --since "2024-12-14 14:00:00" --until "2024-12-14 14:05:00"
```

## Filtering by Priority (`-p`)

`journald` categorizes messages by severity. You can filter to see only the important ones.

The priorities, from most to least severe, are:
`emerg` (0), `alert` (1), `crit` (2), `err` (3), `warning` (4), `notice` (5), `info` (6), `debug` (7).

```bash title="Show all errors and more critical messages"
journalctl -p err
```
This will show `err`, `crit`, `alert`, and `emerg` messages.

```bash title="Show only informational messages"
journalctl -p info
```

## Combining Filters: The Ultimate Troubleshooting Tool

The true power of `journalctl` comes from combining these filters.

**Scenario:** Your web server had a problem this morning. Find all errors from the `nginx` service between 8:00 and 9:00 AM.

```bash
journalctl -u nginx --since "08:00" --until "09:00" -p err
```
This single command pinpoints the exact information you need from potentially millions of log entries.

## Changing Output Format (`-o`)

The `-o` flag controls how the logs are displayed.

-   `short`: The default, human-readable format.
-   `verbose`: Shows all stored metadata for each entry.
-   `json-pretty`: Outputs in a nicely formatted JSON structure, perfect for piping to other tools.

```bash title="View logs as JSON"
journalctl -n 5 -o json-pretty
```

## Viewing Kernel Messages (`-k`)

To see only messages from the Linux kernel (the equivalent of the `dmesg` command), use the `-k` flag.

```bash title="Show recent kernel messages"
journalctl -k -n 20
```
This is useful for debugging hardware, driver, or boot-related issues.

## Persistent vs. Volatile Logs

By default, on some systems, the journal is "volatile" and stored in `/run/log/journal/`, which is cleared on reboot. To make logs persist across reboots, `systemd` needs to store them in `/var/log/journal/`.

**To enable persistent logging:**
```bash
sudo mkdir -p /var/log/journal
sudo systemctl restart systemd-journald
```
You can also edit `/etc/systemd/journald.conf` and set `Storage=persistent`.

## Practice Exercises

**Exercise 1: Check a Service**
Show the last 50 log entries for your `sshd` service.
```bash
journalctl -u sshd -n 50
```

**Exercise 2: Find Errors**
Find all log entries with a priority of `warning` or higher that have occurred since yesterday.
```bash
journalctl -p warning --since yesterday
```

**Exercise 3: Live-Follow with Filtering**
In one terminal, follow the journal in real-time. In another terminal, restart a service like `cron` (`sudo systemctl restart cron`). Watch the log entries for the stop and start events appear in the first terminal.
```bash
# Terminal 1
journalctl -f

# Terminal 2
sudo systemctl restart cron
```

## Key Takeaways
-   `journalctl` is the modern tool for querying `systemd` logs.
-   It offers powerful filtering by **unit (service)**, **time**, and **priority**.
-   **`journalctl -u [service]`**: Your go-to for service-specific logs.
-   **`journalctl -f`**: Your go-to for live log monitoring.
-   **`journalctl -p [priority]`**: Your go-to for filtering out noise.
-   Combine filters (`-u`, `--since`, `-p`) to quickly zero in on problems.
-   Logs can be made persistent by creating `/var/log/journal`.

While `tail` and `grep` on text files in `/var/log` still have their place, `journalctl` provides a more structured and powerful way to interact with your system's logs. Mastering it will make you a faster and more effective troubleshooter.
