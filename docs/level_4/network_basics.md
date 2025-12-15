# Network Basics: ping, curl, and wget

!!! quote "The first tools for any connectivity issue"

## Is It a Network Problem?

"The site is down!" "The app can't connect to the database." "I can't download the update."

Sooner or later, you'll run into a problem, and the first question you need to answer is: "Is it a network problem?" Can your server reach the outside world? Can it connect to other services? Is DNS working?

Three fundamental commands form the basis of all command-line network troubleshooting and interaction:
-   **`ping`**: "Are you there?" - Checks basic connectivity and latency.
-   **`curl`**: The Swiss Army knife for URLs. It talks to web services.
-   **`wget`**: The straightforward file downloader.

Mastering these three tools will allow you to diagnose a huge range of connectivity issues.

## `ping`: Is Anyone Home?

`ping` is the simplest network utility. It sends a small packet (an ICMP "echo request") to a host and waits for a reply.

**Purpose:** To check if a remote host is reachable and how long the round-trip takes (latency).

```bash
ping google.com
```
**Output:**
```
PING google.com (142.250.72.238) 56(84) bytes of data.
64 bytes from lhr4s01-in-f14.1e100.net (142.250.72.238): icmp_seq=1 ttl=118 time=12.5 ms
64 bytes from lhr4s01-in-f14.1e100.net (142.250.72.238): icmp_seq=2 ttl=118 time=12.4 ms
64 bytes from lhr4s01-in-f14.1e100.net (142.250.72.238): icmp_seq=3 ttl=118 time=12.6 ms
...
--- google.com ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2003ms
rtt min/avg/max/mdev = 12.400/12.500/12.600/0.088 ms
```
Press `Ctrl+C` to stop.

**Reading the Output:**
-   `64 bytes from ...`: A reply was received. The server is up!
-   `time=12.5 ms`: The round-trip time (latency). Lower is better.
-   `0% packet loss`: All our packets made it there and back.
-   `ping: connect: Name or service not known`: DNS issue. Your server couldn't figure out the IP address for "google.com".
-   `100% packet loss`: Your server can't reach the target. It could be down, or more likely, a firewall is blocking the ping.

### Limiting Ping Count (`-c`)

By default, `ping` runs forever. Use the `-c` flag to send a specific number of packets.

```bash title="Send 4 pings to a specific IP"
ping -c 4 8.8.8.8
```

This is perfect for scripts or a quick check.

## `curl`: The Swiss Army Knife for URLs

`curl` (Client for URLs) is an incredibly powerful tool for transferring data. It can speak dozens of protocols, but you'll mostly use it for HTTP(S) to interact with websites and APIs.

By default, `curl` prints the full response body to your terminal.

```bash title="Get the HTML of a website"
curl https://example.com
```

### Checking Headers (`-I` or `--head`)

Often, you don't need the page content, just the status. The `-I` flag fetches only the HTTP headers.

```bash title="Check if a website is up"
curl -I https://google.com
```
**Output:**
```
HTTP/2 301
location: https://www.google.com/
...
```
-   `HTTP/2 200`: The status code. `200 OK` means success.
-   `HTTP/2 301`: A redirect. `curl` doesn't follow redirects by default.
-   `HTTP/2 404`: Not Found.
-   `HTTP/2 500`: Server Error.

### Following Redirects (`-L`)

To make `curl` follow redirects (like the 301 above), use `-L`.

```bash title="Follow redirects to the final destination"
curl -IL https://google.com
```
Now you'll see the headers for the redirect *and* the final `200 OK` response from `www.google.com`.

### Saving Output to a File (`-o` and `-O`)

-   `-o` (lowercase): Save output to a specific filename.
-   `-O` (uppercase): Save output to a file named after the remote file.

```bash title="Save to a specific file"
curl -o google_home.html https://www.google.com
```

```bash title="Save to a file named 'latest.tar.gz'"
curl -O https://wordpress.org/latest.tar.gz
```

### Testing APIs

This is where `curl` shines. You can test API endpoints directly from the command line.

```bash title="Test a JSON API endpoint"
curl https://api.github.com/users/torvalds
```
This will dump the JSON response to your terminal.

You can also send data with `-X POST` and `-d`.
```bash title="Send POST data to an API"
curl -X POST -d '{"name":"Brad", "job":"Dev"}' https://reqres.in/api/users
```

## `wget`: The Simple Downloader

While `curl` can download files, `wget` is often simpler for that specific task. It's a non-interactive downloader that's great for scripts.

```bash title="Download a file"
wget https://wordpress.org/latest.tar.gz
```
This downloads `latest.tar.gz` into your current directory and shows a nice progress bar.

### Key `wget` Features

-   **Resuming Downloads (`-c`):** If a download gets interrupted, `wget -c [URL]` will resume where it left off.
-   **Saving to a Different Name (`-O`):**
    ```bash
    wget -O wordpress.zip https://wordpress.org/latest.zip
    ```
-   **Recursive Downloading (`-r`):** `wget` can download an entire website. (Use with caution!)
    ```bash
    wget -r --level=1 https://example.com
    ```

## `curl` vs. `wget`: What's the Difference?

| Feature | `curl` | `wget` |
|:---|:---|:---|
| **Primary Purpose**| Data transfer (Swiss Army knife)| File downloading |
| **Default Output**| `stdout` (prints to screen) | Saves to a file |
| **Protocols** | Dozens (HTTP, HTTPS, FTP, SCP, etc.)| Fewer (HTTP, HTTPS, FTP) |
| **Library Support**| Backed by `libcurl`, used in thousands of apps| Standalone executable |
| **Common Use** | API testing, scripting, quick checks| Downloading files, mirroring sites |

**Simple rule of thumb:**
-   If you want to **see** the content of a URL or test an API, use `curl`.
-   If you want to **download** a file, use `wget`.

## Practice Exercises

**Exercise 1: Check Connectivity**
Ping `8.8.8.8` (a Google DNS server) to check your raw internet connectivity. Then ping `a-domain-that-does-not-exist.com` to see a DNS failure.
```bash
ping -c 3 8.8.8.8
ping -c 3 a-domain-that-does-not-exist.com
```

**Exercise 2: Download a File**
Use `wget` to download the latest release of WordPress. Then, use `ls -l` to see the downloaded file.
```bash
wget https://wordpress.org/latest.tar.gz
ls -l latest.tar.gz
```

**Exercise 3: Test an API**
Use `curl` to get information about the public IP address you're using.
```bash
curl https://ipinfo.io/ip
```

## Key Takeaways
-   **`ping`** checks basic "is it on?" connectivity and latency.
-   **`curl`** is a versatile tool for interacting with URLs, perfect for API testing and seeing response headers/content.
-   **`wget`** is a straightforward, reliable tool for downloading files.
-   If `ping [hostname]` fails but `ping [IP]` works, you have a **DNS problem**.
-   If `ping` fails entirely, you have a **network connectivity problem** (or a firewall is blocking you).
-   If `ping` works but `curl` fails, the server is up but the web service on it might be down.
