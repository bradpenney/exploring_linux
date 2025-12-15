# Network Diagnostics: ip, ss, and netstat

!!! quote "Inspecting the state of your network interfaces and connections"

## Beyond "Is It On?"

You can `ping` a server to see if it's reachable and `curl` a website to see if it's up. But what about your own server's network configuration?
-   What's my IP address?
-   What network services are listening for connections?
-   Who is connected to my server right now?
-   How does my server know how to reach the internet?

To answer these questions, you need to move beyond basic connectivity tools and use network diagnostic commands. The modern toolkit consists of `ip` and `ss`, which replace the older, classic tools `ifconfig` and `netstat`.

## `ip`: Your Network Configuration Hub

The `ip` command is a powerful multitool that replaces several older commands (`ifconfig`, `route`, `arp`). Think of it as the main control panel for network interfaces and routing.

### `ip addr show`: What's My IP Address?

The most fundamental question. Use `ip addr show`, or the shorter `ip a`.

```bash
ip a
```
**Output:**
```
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 52:54:00:12:34:56 brd ff:ff:ff:ff:ff:ff
    inet 192.168.122.10/24 brd 192.168.122.255 scope global dynamic eth0
       valid_lft 85655sec preferred_lft 85655sec
```

**How to read this:**
-   `lo`: The loopback interface. It's always there and its IP is `127.0.0.1`. It's how the machine talks to itself.
-   `eth0`: A physical network interface (an "Ethernet" card).
-   `link/ether 52:54:00:12:34:56`: The MAC address (hardware address) of the interface.
-   `inet 192.168.122.10/24`: **This is your IP address.** The `/24` is the netmask, indicating the size of the network.

### `ip route show`: How Do I Get Out?

How does your server know where to send traffic destined for the internet? It uses a routing table.

```bash
ip route show
```
**Output:**
```
default via 192.168.122.1 dev eth0 proto dhcp src 192.168.122.10 metric 100
192.168.122.0/24 dev eth0 proto kernel scope link src 192.168.122.10 metric 100
```
The most important line is the one that starts with `default`. This is your **default gateway**. It means "for any traffic I don't have a specific rule for, send it to `192.168.122.1` via the `eth0` interface." This is how your server reaches the internet.

## `ss`: The Socket Statistics Investigator

A "socket" is one endpoint of a network connection. To see what connections are open, what ports are being listened on, and who is connected, you use `ss`. It replaces the older, slower `netstat`.

### `ss -tuln`: What's Listening?

This is the most common `ss` command you will ever type. It answers the question: "What ports are open and listening for connections on this server?"

-   `-t`: Show **T**CP sockets.
-   `-u`: Show **U**DP sockets.
-   `-l`: Show **l**istening sockets.
-   `-n`: Show **n**umeric addresses and ports (don't resolve DNS or service names).

```bash
sudo ss -tuln
```
**Output:**
```
Netid  State      Local-Address:Port      Peer-Address:Port
...
tcp    LISTEN     0.0.0.0:22              0.0.0.0:*
tcp    LISTEN     0.0.0.0:80              0.0.0.0:*
tcp    LISTEN     127.0.0.1:3306            0.0.0.0:*
...
```
**How to read this:**
-   `tcp LISTEN 0.0.0.0:22`: A TCP socket is listening on port 22 on all available network interfaces (`0.0.0.0`). This is our SSH server.
-   `tcp LISTEN 0.0.0.0:80`: Something is listening on port 80 (HTTP). This is likely a web server.
-   `tcp LISTEN 127.0.0.1:3306`: Something is listening on port 3306, but *only* on the loopback interface (`127.0.0.1`). This is a database that only accepts local connections.

### `ss -tunap`: Who is Using What Port?

Adding the `-p` flag shows the **p**rocess that is using the socket. This is incredibly useful for troubleshooting.

```bash
sudo ss -tunap | grep ":80"
```
**Output:**
```
tcp   LISTEN  0.0.0.0:80    0.0.0.0:*    users:(("nginx",pid=859,fd=6))
```
Now you know for sure: `nginx` (with PID 859) is the process listening on port 80.

## `netstat`: The Classic Tool

`netstat` is deprecated and has been replaced by `ss` and `ip`. However, it's installed on millions of systems, so you should recognize its syntax.

-   `ss -tuln` is equivalent to `netstat -tuln`.
-   `ip a` is equivalent to `ifconfig`.
-   `ip route` is equivalent to `route`.

If you're on an older system and `ss` or `ip` aren't available, `netstat` and `ifconfig` will still get the job done.

## DNS Diagnostics: `dig` and `host`

Sometimes your server can't connect because it can't resolve a domain name to an IP address.

### `dig`: The Deep Dive

`dig` (Domain Information Groper) is the go-to tool for DNS queries.

```bash
dig google.com
```
**Output (abbreviated):**
```
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 12345
;; QUESTION SECTION:
;google.com.			IN	A

;; ANSWER SECTION:
google.com.		299	IN	A	142.250.72.238

;; Query time: 12 msec
;; SERVER: 127.0.0.53#53(127.0.0.53)
```
-   `status: NOERROR`: The query was successful.
-   `ANSWER SECTION`: The important part. It shows that `google.com` has an `A` record (an IPv4 address) of `142.250.72.238`.
-   `SERVER`: The DNS server that answered the query.

### `host`: The Simple Lookup

The `host` command is a simpler alternative to `dig`.

```bash
host google.com
```
**Output:**
```
google.com has address 142.250.72.238
google.com has IPv6 address 2a00:1450:4009:820::200e
google.com mail is handled by 10 aspmx.l.google.com.
...
```
It gives you the most important records in a clean, human-readable format.

## Practical Scenarios

**"What is this server's IP address?"**
```bash
ip a
```

**"Is my web server actually listening on port 443 (HTTPS)?"**
```bash
sudo ss -tuln | grep ":443"
```

**"Some process is using port 8080. What is it?"**
```bash
sudo ss -tunap | grep ":8080"
```

**"Why can't I connect to `db.example.com`?"**
```bash
# Step 1: Can I resolve the name?
dig db.example.com
# If this fails, it's a DNS problem. Check /etc/resolv.conf.

# Step 2: Can I reach the IP?
ping <IP_from_dig>
# If this fails, it's a network/firewall problem.
```

## Practice Exercises

**Exercise 1: Inspect Your Interfaces**
Run `ip a` on your machine. Identify your main network interface (e.g., `eth0` or `wlan0`) and find its IP address and MAC address.

**Exercise 2: Find Listening Services**
Run `sudo ss -tuln`. What services are listening on your machine? Can you identify SSH (port 22)? What about any web servers (port 80 or 443)?

**Exercise 3: Find a Process**
Run `sudo ss -tunap`. Find a service you recognize (like `sshd`) and identify its PID. Verify this PID using `ps aux | grep sshd`.

## Key Takeaways
-   **`ip`** is the modern tool for managing network **interfaces** and **routes**.
    -   `ip a`: Show IP addresses.
    -   `ip route`: Show routing table.
-   **`ss`** is the modern tool for inspecting network **sockets** (connections).
    -   `ss -tuln`: Shows what ports are listening.
    -   `ss -tunap`: Shows what processes are using what ports.
-   `netstat` and `ifconfig` are older, deprecated tools, but you should recognize them.
-   **`dig`** and **`host`** are used to diagnose DNS problems.
-   If you can't connect, your troubleshooting flow should be: **DNS -> Network -> Service**. (Can I resolve it? Can I ping it? Is the service listening on the port?).
