# Working Efficiently with Remote Systems

You've connected to a few servers. You know the basics. Now let's make your daily workflow smoother.

These aren't "must-know" survival skills - these are quality-of-life improvements that save time and frustration when you're working with remote Linux systems regularly.

---

## SSH Config File - Stop Typing the Same Commands

If you're typing `ssh -i ~/.ssh/mykey.pem username@really-long-hostname.example.com` every day, you're working too hard.

SSH has a configuration file that lets you save connection details and create shortcuts.

### Create Your SSH Config

The file lives at `~/.ssh/config` (on your local machine, not the server).

``` bash title="Create SSH Config (if it doesn't exist)"
touch ~/.ssh/config
chmod 600 ~/.ssh/config
```

### Basic Configuration Example

``` bash title="~/.ssh/config"
Host staging
    HostName staging.example.com
    User jsmith
    Port 22
    IdentityFile ~/.ssh/my_key.pem

Host prod
    HostName 192.168.1.100
    User admin
    IdentityFile ~/.ssh/prod_key.pem
    Port 2222
```

Now instead of:

``` bash title="The Long Way"
ssh -i ~/.ssh/my_key.pem -p 22 jsmith@staging.example.com
```

You can just type:

``` bash title="The Short Way"
ssh staging
```

**What you're saving:**
- No more remembering IP addresses
- No more typing usernames
- No more specifying key files
- No more remembering custom ports

### Configuration Options

Here are the most useful SSH config options:

| Option | Purpose | Example |
|--------|---------|---------|
| `Host` | Shortcut name | `Host myserver` |
| `HostName` | Actual hostname/IP | `HostName 192.168.1.100` |
| `User` | Username | `User jsmith` |
| `Port` | SSH port | `Port 2222` |
| `IdentityFile` | Private key path | `IdentityFile ~/.ssh/mykey.pem` |
| `ServerAliveInterval` | Keep connection alive | `ServerAliveInterval 60` |
| `ServerAliveCountMax` | Retry count | `ServerAliveCountMax 3` |
| `ForwardAgent` | SSH agent forwarding | `ForwardAgent yes` |

### Keep Connections Alive

Tired of SSH disconnecting when you step away from your desk? Add this to prevent idle timeouts:

``` bash title="Keep Connections Alive (in ~/.ssh/config)"
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

**What this does:**
- Sends a keepalive packet every 60 seconds
- Tries 3 times before giving up
- Prevents idle disconnections from firewalls

The `Host *` means "apply to all connections." You can also add this to specific host entries.

### Multiple Environments Pattern

Common pattern for developers managing multiple environments:

``` bash title="~/.ssh/config - Multiple Environments"
# Development
Host dev
    HostName dev-server.company.com
    User jsmith
    IdentityFile ~/.ssh/id_rsa

# Staging
Host staging
    HostName staging-server.company.com
    User jsmith
    IdentityFile ~/.ssh/id_rsa

# Production (extra careful!)
Host prod
    HostName prod-server.company.com
    User jsmith-readonly
    IdentityFile ~/.ssh/prod_readonly.pem
```

Now you can quickly connect:
- `ssh dev` - Development environment
- `ssh staging` - Staging environment
- `ssh prod` - Production (read-only account)

---

## Terminal Multiplexers - Work Across Disconnections

SSH connections drop. Networks hiccup. Your laptop suspends. But your work shouldn't disappear.

This is what terminal multiplexers solve. We'll cover two popular options:

### tmux (Recommended)

**What it does:** Keeps your terminal sessions running even when you disconnect.

**Basic workflow:**

``` bash title="Start a tmux Session"
tmux new -s work
# Now you're inside tmux - run your commands
# If you disconnect and reconnect, your session is still there
```

``` bash title="Reconnect to Your Session"
ssh myserver
tmux attach -t work
# Everything is exactly as you left it
```

**Most useful tmux commands:**

| Key Combo | What It Does |
|-----------|--------------|
| `Ctrl+b d` | Detach (leave session running) |
| `Ctrl+b c` | Create new window |
| `Ctrl+b n` | Next window |
| `Ctrl+b p` | Previous window |
| `Ctrl+b %` | Split pane vertically |
| `Ctrl+b "` | Split pane horizontally |

**Why this matters:**
- Long-running commands keep running if you disconnect
- Server reboots? No problem, just reconnect
- Multiple terminal windows on the same server
- Split screen to watch logs while running commands

### screen (Alternative)

**What it does:** Same concept as tmux, older and more ubiquitous.

``` bash title="Start a screen Session"
screen -S work
```

``` bash title="Reconnect to Your Session"
screen -r work
```

**Most useful screen commands:**

| Key Combo | What It Does |
|-----------|--------------|
| `Ctrl+a d` | Detach |
| `Ctrl+a c` | Create new window |
| `Ctrl+a n` | Next window |
| `Ctrl+a p` | Previous window |

**tmux vs screen:** Both work. tmux is more modern with better defaults. screen is older but installed on more systems. Pick one and learn it.

---

## SSH Aliases in Your Shell

Don't want to use SSH config? Shell aliases work too:

``` bash title="Add to ~/.bashrc or ~/.zshrc"
alias sshstaging='ssh jsmith@staging.example.com'
alias sshprod='ssh admin@prod-server.company.com -i ~/.ssh/prod_key.pem'
```

After sourcing your shell config (`source ~/.bashrc`), you can use:

``` bash title="Using Aliases"
sshstaging
sshprod
```

**SSH config vs shell aliases:**
- SSH config: Better for complex setups, works with `scp`/`rsync`
- Shell aliases: Simpler, but only works for `ssh` command

---

## Quick Recap

| Tool | Purpose | When to Use |
|------|---------|-------------|
| `~/.ssh/config` | Save connection shortcuts | Connecting to same servers regularly |
| `tmux`/`screen` | Persistent terminal sessions | Long-running tasks, unreliable networks |
| Shell aliases | Quick SSH shortcuts | Simple connections, personal preference |
| ServerAliveInterval | Keep connections alive | Idle timeout issues |

---

## Practice Exercises

??? question "Exercise 1: Create Your SSH Config"
    Set up an SSH config entry for a server you connect to regularly.

    **Goal:** Connect using just `ssh myserver` instead of the full command.

??? tip "Solution"
    ``` bash title="Edit ~/.ssh/config"
    nano ~/.ssh/config
    ```

    Add an entry:

    ```
    Host myserver
        HostName 192.168.1.100
        User yourusername
        IdentityFile ~/.ssh/your_key.pem
    ```

    Save and test: `ssh myserver`

??? question "Exercise 2: Start a tmux Session"
    Connect to a server, start a tmux session, run a command, detach, and reconnect.

    **Goal:** Understand persistent sessions.

??? tip "Solution"
    ``` bash title="Start tmux"
    tmux new -s practice
    ```

    Inside tmux, run something:

    ``` bash title="Run a Command"
    top
    # Press Ctrl+b then d to detach
    ```

    Reconnect:

    ``` bash title="Reattach"
    tmux attach -t practice
    # Your top command is still running!
    ```

??? question "Exercise 3: Add ServerAliveInterval"
    Configure SSH to prevent idle timeouts on all connections.

??? tip "Solution"
    ``` bash title="Edit ~/.ssh/config"
    # Add at the top of the file
    Host *
        ServerAliveInterval 60
        ServerAliveCountMax 3
    ```

    This applies to all SSH connections. The server will keep your connection alive.

---

## Further Reading

- `man ssh_config` - Complete SSH configuration options
- `man tmux` - tmux manual
- `man screen` - screen manual
- [tmux cheat sheet](https://tmuxcheatsheet.com/) - Quick reference for tmux commands
- [SSH Academy - Config File](https://www.ssh.com/academy/ssh/config) - Comprehensive SSH config guide

---

## What's Next?

Now that you can connect efficiently, learn about navigating the filesystem and finding files in the next Level 1 articles.
