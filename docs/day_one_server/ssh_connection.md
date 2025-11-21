# Connecting via SSH

Someone just handed you SSH credentials to a Linux server. Maybe it's an IP address scrawled on a sticky note, maybe it's in a Slack message, maybe it's buried in your onboarding docs. Either way, you need to connect to this mysterious box and you're not quite sure how.

**Let's fix that.**

SSH (Secure Shell) is how you connect to remote Linux servers. It's encrypted, it's standard, and once you've done it a few times, it becomes second nature.

## What You'll Need

Before you connect, make sure you have:

- **Hostname or IP address** - Where's the server? (`192.168.1.100` or `server.example.com`)
- **Username** - Who are you logging in as? (often your company username)
- **Credentials** - Either a password or an SSH key (we'll cover both)

That's it. Now let's get you connected based on what operating system you're using.

---

## Connecting from Linux or Mac

Good news: SSH comes pre-installed on every Linux distribution and macOS. Open your terminal and you're ready to go.

### Basic Connection

``` bash title="SSH with Password"
ssh username@hostname
```

Real example:

``` bash title="Connecting to a Server"
ssh jsmith@192.168.1.100
# or
ssh jsmith@staging.example.com
```

**What happens next:**

1. First time connecting? You'll see a fingerprint warning (we'll explain this in a moment)
2. Enter your password when prompted
3. You're in! You should see the server's command prompt

### First Connection - The Fingerprint Warning

The first time you connect to a server, you'll see something scary:

```
The authenticity of host '192.168.1.100 (192.168.1.100)' can't be established.
ED25519 key fingerprint is SHA256:abc123def456...
Are you sure you want to continue connecting (yes/no/[fingerprint])?
```

**Don't panic.** This is SSH asking "Is this really the server you meant to connect to?"

Type `yes` and press Enter. SSH will remember this server and won't ask again (unless the server's key changes, which could indicate a security issue).

### SSH with a Specific Port

Most SSH servers listen on port 22, but some use custom ports for security. If your server uses a different port:

``` bash title="SSH on Custom Port"
ssh -p 2222 username@hostname
```

### Using SSH Keys Instead of Passwords

SSH keys are more secure and convenient than passwords. If someone gave you a private key file (usually named `id_rsa` or similar):

``` bash title="SSH with Key File"
ssh -i /path/to/private_key username@hostname
```

Example:

``` bash title="Using a Downloaded Key"
ssh -i ~/Downloads/my_server_key.pem ec2-user@ec2-54-123-45-67.compute.amazonaws.com
```

!!! warning "Key File Permissions"
    SSH is picky about key file permissions. If you get a "permissions are too open" error:

    ``` bash title="Fix Key Permissions"
    chmod 600 /path/to/private_key
    ```

---

## Connecting from Windows

Windows has a few options for SSH. Let's cover them from easiest to most powerful.

### Option 1: Windows Terminal (Recommended)

**Windows 10/11 includes OpenSSH by default.** Open Windows Terminal (or PowerShell) and use the same commands as Linux/Mac:

``` bash title="SSH from Windows Terminal"
ssh username@hostname
```

That's it! Same syntax, same behavior.

### Option 2: PuTTY (Traditional Approach)

PuTTY has been the Windows SSH client for decades. It's still popular but requires a GUI instead of command-line simplicity.

**Download:** [PuTTY official site](https://www.putty.org/)

**Steps:**

1. Launch PuTTY
2. Enter hostname/IP in "Host Name" field
3. Port: 22 (unless told otherwise)
4. Connection type: SSH
5. Click "Open"
6. Enter username and password when prompted

**Using SSH keys with PuTTY:**

PuTTY uses `.ppk` format instead of standard SSH keys. If you have a `.pem` or `id_rsa` file, convert it using **PuTTYgen** (included with PuTTY):

1. Open PuTTYgen
2. Load your existing private key
3. Save as `.ppk` format
4. In PuTTY: Connection → SSH → Auth → Browse to your `.ppk` file

### Option 3: WSL (Windows Subsystem for Linux)

If you installed Linux via WSL, you've got full SSH capabilities. Just open your WSL terminal and use the Linux instructions above.

---

## Saving Connections (SSH Config)

Typing long SSH commands gets old fast. Save yourself time with SSH config files.

**Create/edit:** `~/.ssh/config`

``` bash title="Example SSH Config"
Host staging
    HostName staging.example.com
    User jsmith
    Port 22
    IdentityFile ~/.ssh/my_key.pem

Host prod
    HostName 192.168.1.100
    User admin
    IdentityFile ~/.ssh/prod_key.pem
```

Now you can connect with just:

``` bash title="Using SSH Aliases"
ssh staging
# or
ssh prod
```

Way easier than remembering hostnames, usernames, ports, and key files!

---

## Troubleshooting Common Issues

Even experienced users hit these snags:

### Connection Refused

```
ssh: connect to host 192.168.1.100 port 22: Connection refused
```

**Possible causes:**

- Server is down or unreachable
- Firewall blocking port 22
- SSH service not running on the server
- Wrong IP address or hostname

**What to try:**

``` bash title="Test Server Connectivity"
ping 192.168.1.100
# Can you reach the server at all?
```

Ask your team: Is the server running? Is there a VPN you need to connect to first?

### Connection Timeout

```
ssh: connect to host server.example.com port 22: Connection timed out
```

**Likely causes:**

- Network issue (firewall, VPN, wrong network)
- Server is on a private network you don't have access to
- DNS issue (can't resolve hostname)

**What to try:**

- Are you on the company VPN?
- Can you ping the server?
- Try the IP address instead of hostname (or vice versa)

### Permission Denied (Publickey)

```
Permission denied (publickey).
```

**This means:** The server requires SSH key authentication and either:

- You didn't specify a key file (`-i` flag)
- Your key isn't authorized on the server
- Key file permissions are wrong

**What to try:**

``` bash title="Specify Your Key"
ssh -i ~/.ssh/your_key username@hostname
```

Check with your team: Which key should you be using? Has your public key been added to the server?

### Host Key Verification Failed

```
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
```

**This means:** The server's fingerprint changed since you last connected.

**Possible causes:**

- Server was rebuilt or its SSH keys regenerated (normal)
- Someone is intercepting your connection (rare but serious!)

**What to do:**

1. Ask your team: "Did the staging server get rebuilt recently?"
2. If yes, remove the old fingerprint:

``` bash title="Remove Old Fingerprint"
ssh-keygen -R hostname
# or
ssh-keygen -R 192.168.1.100
```

Then reconnect and accept the new fingerprint.

---

## Quick Recap

**Linux/Mac:**
``` bash
ssh username@hostname
```

**Windows:**

- Windows Terminal: Same as Linux/Mac
- PuTTY: GUI-based, requires `.ppk` keys
- WSL: Full Linux SSH experience

**With SSH key:**
``` bash
ssh -i /path/to/key username@hostname
```

**Save time with SSH config:**
Create `~/.ssh/config` with your common connections.

---

## What's Next?

You're connected! The server's command prompt is staring back at you. Now what?

Head to [First 60 Seconds: Orientation](orientation.md) to learn what to do in those first moments after login - where you are, who you are, and what this server actually is.

!!! tip "Pro Tip: Keep Your Connection Alive"
    If your SSH session disconnects after being idle, add this to `~/.ssh/config`:

    ```
    Host *
        ServerAliveInterval 60
    ```

    This sends a keepalive packet every 60 seconds.
