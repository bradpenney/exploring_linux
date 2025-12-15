# Managing Services: systemd and systemctl

!!! quote "The conductor of your Linux orchestra"

## The Background Orchestra

Your Linux system isn't just the commands you run. It's a bustling ecosystem of programs running silently in the background, waiting for something to do. These background programs are called **services** or **daemons**.

-   The web server waiting for a connection (`nginx`, `apache2`).
-   The database server managing your data (`mysqld`, `postgresql`).
-   The SSH server listening for your login (`sshd`).
-   The scheduler that runs jobs at specific times (`cron`).

On modern Linux systems, this orchestra is conducted by **`systemd`**, the system and service manager. Your primary tool for interacting with `systemd` is the powerful `systemctl` command.

## The `systemctl` Verbs: Your Control Panel

`systemctl` uses a "verb-noun" syntax, like `systemctl status nginx.service`. You don't always need the `.service` suffix.

Here are the essential verbs you'll use to manage services.

| Verb | What It Does | Analogy |
|:---|:---|:---|
| `status` | Check if a service is running. | "Is the web server open for business?" |
| `start` | Start a service now. | "Open the shop." |
| `stop` | Stop a service now. | "Close the shop for the day." |
| `restart`| Stop and then immediately start a service. | "Close up, then immediately reopen."|
| `reload` | Reload configuration without stopping. | "Tell the chef about a menu change without closing the kitchen." |
| `enable` | Make a service start automatically on boot. | "Add this shop to the list of businesses that open automatically every morning."|
| `disable`| Prevent a service from starting on boot. | "Remove this shop from the automatic opening list." |

---

### `status`: Checking on a Service

This is your first stop for troubleshooting. `systemctl status` gives you a wealth of information.

```bash
systemctl status sshd
```

**Output:**
```
● sshd.service - OpenSSH server daemon
     Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor preset: enabled)
     Active: active (running) since Wed 2024-12-14 10:00:00 UTC; 1 weeks 2 days ago
   Main PID: 987 (sshd)
      Tasks: 1 (limit: 11110)
     Memory: 5.7M
        CPU: 1.522s
     CGroup: /system.slice/sshd.service
             └─987 /usr/sbin/sshd -D

Dec 14 10:00:00 my-server systemd[1]: Started OpenSSH server daemon.
Dec 15 09:30:15 my-server sshd[12345]: Accepted publickey for brad from 192.168.1.100 port 54321
```

**Key parts to read:**
-   `Loaded: ... enabled`: This service is configured to start on boot. If it said `disabled`, it would not.
-   `Active: active (running)`: **It's currently running.** This is what you want to see.
    -   `inactive (dead)`: The service is stopped.
    -   `failed`: The service tried to start but crashed.
-   `Main PID`: The Process ID of the main service process.
-   The last few lines are recent log entries from `journald`.

---

### `start`, `stop`, `restart`: Controlling a Service

These commands control the live state of a service. They almost always require `sudo`.

```bash title="Stop the web server"
sudo systemctl stop nginx
```

```bash title="Start the web server"
sudo systemctl start nginx
```

`restart` is a common operation after changing a configuration file. It's a convenient shortcut for a `stop` followed by a `start`.

```bash title="Restart the database service"
sudo systemctl restart postgresql
```

---

### `reload`: The Graceful Way to Update

Restarting a service causes downtime. Even for a second, a `restart` on a web server will drop active connections.

Many services can reload their configuration files without a full restart. This is the **preferred** method for applying configuration changes.

```bash title="Apply new nginx config without downtime"
sudo systemctl reload nginx
```

If a service doesn't support `reload`, `systemd` is smart enough to fall back to a full `restart`. You can also use `reload-or-restart`.

---

### `enable`, `disable`: Controlling Boot Behavior

`start` and `stop` control the service *right now*. `enable` and `disable` control what happens when the computer **boots up**.

When you install a web server, you want it to start automatically every time the machine boots.

```bash title="Make nginx start on boot"
sudo systemctl enable nginx
```

If you decide you don't want it to run anymore:

```bash title="Prevent nginx from starting on boot"
sudo systemctl disable nginx
```

!!! tip "Enable vs. Start"
    A common beginner mistake is to `enable` a service and wonder why it's not running. `enable` only affects the *next boot*. You need to `start` it to run it *now*.
    **The common pattern is:**
    `sudo systemctl enable --now nginx`
    The `--now` flag both enables and starts the service in one command.

---

## Understanding Unit Files

How does `systemd` know how to start, stop, and manage `nginx`? It reads a **unit file**. These are simple text files that act as a "manual" for a service.

-   They usually end in `.service`.
-   They live in `/etc/systemd/system/` (for custom/overridden files) or `/lib/systemd/system/` (for defaults from installed packages).

You can view a service's unit file with `systemctl cat`.

```bash
systemctl cat nginx.service
```
**Output (simplified):**
```ini
[Unit]
Description=A high performance web server
After=network.target

[Service]
Type=forking
PIDFile=/run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t -q -g 'daemon on; master_process on;'
ExecStart=/usr/sbin/nginx -g 'daemon on; master_process on;'
ExecReload=/usr/sbin/nginx -s reload
ExecStop=-/sbin/start-stop-daemon --quiet --stop --retry QUIT/5 --pidfile /run/nginx.pid

[Install]
WantedBy=multi-user.target
```
You don't need to understand everything here yet, but notice the `ExecStart`, `ExecReload`, and `ExecStop` lines. These are the exact commands `systemd` runs when you tell it to `start`, `reload`, or `stop` the service.

## Viewing Logs with `journalctl`

`systemd` has its own logging system called the **journal**. The `journalctl` command is your window into these logs.

This is often more powerful than reading log files in `/var/log` because it aggregates logs from all `systemd` services.

### Logs for a Specific Service

This is the most common use case.

```bash title="Show all logs for the nginx service"
journalctl -u nginx.service
```

### Following Logs in Real-Time

Just like `tail -f`.

```bash title="Follow nginx logs live"
journalctl -u nginx.service -f
```

### Filtering by Time

```bash title="Show logs from the last 30 minutes"
journalctl -u nginx.service --since "30 minutes ago"
```

### Filtering by Priority

Show only errors and more critical messages.

```bash title="Show only errors for a service"
journalctl -u nginx.service -p err
```

## Practice Exercises

**Exercise 1: Check a Core Service**
Check the status of the `sshd` service. Is it active? Is it enabled to start on boot?
```bash
systemctl status sshd
```

**Exercise 2: The Enable/Start/Stop Cycle**
1.  Install a simple service: `sudo apt install vsftpd` (an FTP server).
2.  Check its status. Is it running? Is it enabled? (`systemctl status vsftpd`)
3.  Stop it: `sudo systemctl stop vsftpd`. Check its status again.
4.  Start it: `sudo systemctl start vsftpd`. Check its status again.
5.  Enable it to start on boot: `sudo systemctl enable vsftpd`.

**Exercise 3: Find Service Errors**
Use `journalctl` to find any error-level (`err`) messages for the `sshd` service since yesterday.
```bash
sudo journalctl -u sshd -p err --since yesterday
```

## Key Takeaways
-   **Services** (daemons) are background programs.
-   **`systemd`** is the service manager on most modern Linux systems.
-   **`systemctl`** is the command to control `systemd`.
-   **`status`** is your first command for checking on a service.
-   **`start`/`stop`/`restart`** control the live state.
-   **`enable`/`disable`** control the boot-time behavior.
-   Use `reload` to apply configuration changes gracefully without downtime.
-   **`journalctl -u [service]`** is the best way to view logs for a specific service.
