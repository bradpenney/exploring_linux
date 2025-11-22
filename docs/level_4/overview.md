# Level 4: System Management

!!! quote "A little more sysadmin flavoured"

## Welcome to Level 4

You understand files, processes, and permissions. Now it's time to manage the system itself - services that run in the background, network connectivity, disk space, and the archives that move data around.

**This level takes you deeper.** You're moving from "using Linux" to "administering Linux."

## What You'll Master

These are the tools system administrators use daily, and developers benefit from knowing:

- **Services** - `systemctl`, `service`, `journalctl`
- **Networking basics** - `ping`, `curl`, `wget`
- **Network diagnostics** - `netstat`, `ss`, `ip`
- **Disk space** - `df`, `du`, `mount`, `umount`
- **Archives** - `tar`, `gzip`, `zip`

## Who This Level Is For

**Perfect for:**

- Anyone who's completed Level 3
- Developers who need to manage services or troubleshoot connectivity
- Aspiring system administrators
- Anyone dealing with "disk full" errors or network issues

**Prerequisites:**

You should understand processes, permissions, and basic system navigation. If you're not there yet, complete [Level 1](../level_1/overview.md), [Level 2](../level_2/overview.md), and [Level 3](../level_3/overview.md) first.

## The Skills

Learn these system management fundamentals:

1. **[Managing Services](../tuning/systemd.md)** - systemctl, service - start, stop, enable
2. **[Reading Logs](journalctl.md)** - journalctl deep dive - system logs made easy
3. **[Network Basics](network_basics.md)** - ping, curl, wget - basic connectivity
4. **[Network Diagnostics](network_diagnostics.md)** - netstat, ss, ip - troubleshooting
5. **[Disk Space Management](disk_space.md)** - df, du - finding what's using space
6. **[Working with Archives](archives.md)** - tar, gzip, zip - compress and extract
7. **[Adding Storage](../administering_linux/adding_storage.md)** - Disk management
8. **[Accessing Network Storage](../administering_linux/accessing_network_storage.md)** - Mounting shares

## What's Next?

Once you've got system management basics down, you're ready for [Level 5: Under the Hood](../level_5/overview.md). That's where we peek into Linux internals - boot process, /proc filesystem, namespaces, and memory management.

## The Philosophy

**System management is about understanding state.** Is the service running? Is there enough disk space? Can we reach the network? These aren't academic questions - they're the difference between "it works" and "it's broken."

**Logs tell the story.** When something goes wrong, logs are your first stop. Learning to read them efficiently (journalctl, grep, tail -f) is a superpower.

## Real-World Scenarios

These skills solve daily operational problems:

- "The web server isn't responding" → `systemctl status nginx`
- "Can we reach the database?" → `ping db.example.com`
- "The disk is full!" → `df -h` + `du -sh /*` to find the culprit
- "I need to send these logs to support" → `tar czf logs.tar.gz /var/log/app/`
- "Why did the service crash?" → `journalctl -u servicename -n 100`
- "Is port 8080 listening?" → `netstat -tlnp | grep 8080`

Master these, and you can keep systems running smoothly.

Time to level up to sysadmin skills.
