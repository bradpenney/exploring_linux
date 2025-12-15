# Now What? Next Steps

!!! quote "You've got Linux - let's put it to use"

## You Did It

Linux is running. You've logged in, updated the system, maybe installed a few packages. You're looking at a desktop or a command prompt, thinking "Now what?"

**This is the exciting part.** The hard work of installation is done. Now you get to actually use Linux, learn the command line, build things, and develop skills that will serve you for years.

But where do you start? The Linux ecosystem is vast. You could spend a lifetime exploring it.

**This guide points you in the right direction** based on what you want to learn and what you want to accomplish.

## Your Next Steps Depend on Your Goals

Different people have different reasons for learning Linux. Your path forward depends on what you're trying to achieve.

**Choose your adventure:**

- **I want to learn command-line basics** → Start with Level 1
- **I'm preparing for a Linux certification** → Focus on system administration
- **I want to become a DevOps engineer** → Server admin + automation + containers
- **I'm a developer who needs Linux tools** → Development environment setup
- **I want to build projects** → Pick a project, learn as you go
- **I just want to explore** → Try a little of everything

Let's break down each path.

## Path 1: Master the Command Line (Recommended for Everyone)

**No matter your end goal, you need command-line basics.**

Even if you're using desktop Linux, knowing how to navigate the filesystem, manage files, search for content, and get help is foundational.

### Start Here: Level 1 - Everyday Navigation

**Head to [Level 1: Everyday Navigation](../level_1/overview.md)**

This covers the commands you'll use hundreds of times a day:

- Moving around: `ls`, `cd`, `pwd`
- File management: `cp`, `mv`, `rm`, `mkdir`
- Viewing files: `cat`, `less`, `head`, `tail`
- Getting help: `man`, `--help`
- Keyboard shortcuts

**Time investment:** 2-4 hours to read through, weeks to build muscle memory

**Outcome:** Comfortable navigating Linux via command line

### Then: Level 2 - Finding & Filtering

**Continue to [Level 2: Finding & Filtering](../level_2/overview.md)**

Learn to search and manipulate data:

- Finding files: `find`, `locate`, `which`
- Searching content: `grep`, `xargs`
- Shaping output: `sort`, `uniq`, `wc`
- Text manipulation: `cut`, `awk`, `sed`

**Outcome:** Can find anything, anywhere, and extract the data you need

### Keep Going Through the Levels

Each level builds on the previous:

- **Level 3:** Processes, permissions, users
- **Level 4:** Services, networking, disk management
- **Level 5:** Linux internals
- **Level 6:** Scripting and special topics

**By Level 4, you'll have practical sysadmin skills.** By Level 6, you'll understand Linux deeply.

## Path 2: Linux Certification Prep

If you're studying for **CompTIA Linux+**, **LPIC-1**, or **RHCSA**, you need structured system administration knowledge.

### Essential Topics to Cover

1. **System architecture** - Boot process, runlevels/systemd, kernel modules
2. **Package management** - apt/dpkg (Debian/Ubuntu) or yum/rpm (Red Hat/CentOS)
3. **File system** - Hierarchy, permissions, links, mounting
4. **Shell and scripting** - Bash basics, variables, loops, conditionals
5. **User and group management** - useradd, passwd, sudo
6. **Networking** - IP configuration, routing, DNS, SSH
7. **Services** - systemctl, journalctl, service management
8. **Security** - Firewall, SELinux/AppArmor, file permissions

### Recommended Study Plan

1. **Go through Levels 1-4** on this site (command line → system management)
2. **Practice in your Linux environment** - every command, every concept
3. **Set up practice scenarios:**
   - Create users and groups
   - Configure networking
   - Set up web server
   - Manage services
   - Write shell scripts
4. **Use official study guides** for your target certification
5. **Take practice exams**

**Time to certification:** 3-6 months of dedicated study

## Path 3: DevOps / Cloud Engineering

DevOps roles require Linux knowledge plus automation, containers, CI/CD, and cloud platforms.

### Skills to Build

**Foundation (Months 1-2):**

- Command-line proficiency (Levels 1-3)
- Text editors (vim or nano)
- Version control (git)
- SSH, remote access

**System Administration (Months 2-3):**

- User management
- Package management
- Service configuration (systemd)
- Networking basics
- Log management (journalctl)

**Automation (Months 3-4):**

- Shell scripting (bash)
- Configuration management (Ansible basics)
- Cron jobs, scheduled tasks

**Containers (Months 4-5):**

- Docker fundamentals
- Writing Dockerfiles
- Docker Compose
- Container registries

**Cloud Platforms (Months 5-6):**

- AWS/Azure/GCP basics
- Deploying to cloud VMs
- Cloud networking, storage
- Infrastructure as Code (Terraform basics)

**CI/CD (Months 6+):**

- Jenkins or GitHub Actions
- Automated testing
- Deployment pipelines

### Projects to Build

1. **Personal website on cloud VM** - Practice server setup, web server config, DNS
2. **Dockerized application** - Multi-container app with database
3. **Automated deployment pipeline** - Git push triggers build and deploy
4. **Infrastructure as Code** - Terraform to provision cloud resources
5. **Monitoring stack** - Prometheus + Grafana

**Resources:**

- This site (Levels 1-6, especially Levels 4-5)
- Docker documentation
- Cloud provider tutorials (AWS/Azure/GCP)
- DevOps-focused courses (Linux Academy, A Cloud Guru)

## Path 4: Software Development Environment

You're a developer who needs Linux for development work.

### Set Up Your Dev Environment

**Install development tools:**

```bash title="Common development tools"
sudo apt install -y \
  build-essential \
  git \
  vim \
  curl \
  wget
```

**Install language-specific tools:**

**Python:**

```bash
sudo apt install python3 python3-pip python3-venv
```

**Node.js:**

```bash
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs
```

**Rust:**

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

**Go:**

```bash
sudo apt install golang-go
```

**Docker (for containerized development):**

```bash
sudo apt install docker.io
sudo usermod -aG docker $USER
```

Log out and back in for group changes.

### Essential Developer Tools

**Visual Studio Code:**

```bash
sudo snap install code --classic
```

Or download from [https://code.visualstudio.com](https://code.visualstudio.com).

**Terminal multiplexer (tmux or screen):**

```bash
sudo apt install tmux
```

**Database clients:**

```bash
sudo apt install mysql-client postgresql-client
```

**API testing:**

```bash
sudo snap install postman
```

### Learn These Linux Skills

As a developer, focus on:

1. **File navigation** (Level 1) - you'll spend lots of time in terminal
2. **Text searching** (Level 2) - finding code, logs, errors
3. **Process management** (Level 3) - debugging running applications
4. **Version control** - git workflows, branches, merging
5. **Environment variables** - configuration, API keys
6. **SSH** - accessing remote servers, git over SSH

**You don't need deep sysadmin knowledge** unless you're also doing DevOps. Focus on practical development workflow.

## Path 5: Project-Based Learning (My Favorite)

Pick a project, build it, learn Linux along the way.

### Beginner Projects

**Personal website:**

- Set up Apache or Nginx
- Configure virtual hosts
- Learn web server basics

**File server:**

- Samba or NFS
- Network shares
- Permissions and access control

**Media server:**

- Plex or Jellyfin
- Storage management
- Process monitoring

**Ad blocker:**

- Pi-hole (works on Pi or any Linux box)
- DNS configuration
- Network-wide ad blocking

### Intermediate Projects

**Git server:**

- Gitea or Gogs
- User management
- SSH key authentication

**Blog:**

- WordPress, Ghost, or Hugo
- Database setup (MySQL/PostgreSQL)
- Web server configuration
- Domain and DNS

**VPN server:**

- WireGuard or OpenVPN
- Networking concepts
- Security best practices

**Home automation:**

- Home Assistant
- Service management
- Integration with devices

### Advanced Projects

**Kubernetes cluster:**

- Multi-node cluster (or K3s single-node)
- Container orchestration
- Networking, storage, deployments

**CI/CD pipeline:**

- Jenkins or GitLab CI
- Automated testing and deployment
- Docker integration

**Monitoring stack:**

- Prometheus + Grafana
- Node exporter
- Alert manager
- Visualizing metrics

**Private cloud:**

- Nextcloud (personal Dropbox/Google Drive)
- User management
- Storage configuration
- Security hardening

### Why Projects Work

**You learn by doing.** When you hit a problem (and you will), you'll search, troubleshoot, read docs, and solve it. That's real learning.

Plus, you end up with something useful at the end.

## Universal Next Steps (Everyone Should Do These)

Regardless of your path:

### 1. Learn Your Text Editor

Pick **vim** or **nano** and get comfortable:

**Vim:**

- Run `vimtutor` - interactive tutorial built into vim
- Learn basics: `i` (insert), `Esc` (normal mode), `:wq` (save and quit)
- Muscle memory comes with practice

**Nano:**

- Simpler, more intuitive
- All commands shown at bottom of screen
- Perfect for quick edits

### 2. Master SSH

You'll use SSH constantly:

**Generate SSH key:**

```bash
ssh-keygen -t ed25519
```

**Copy public key to remote server:**

```bash
ssh-copy-id user@remote-server
```

**SSH config for convenience:**

```bash
nano ~/.ssh/config
```

Add:

```
Host myserver
    HostName 192.168.1.100
    User myusername
    Port 22
```

Now `ssh myserver` instead of typing full command.

### 3. Customize Your Environment

**Bash aliases** (`~/.bashrc`):

```bash
alias ll='ls -lah'
alias update='sudo apt update && sudo apt upgrade -y'
alias ..='cd ..'
```

**Prompt customization:**

Search for "bash PS1 generator" - customize your command prompt colors and info.

**Dotfiles management:**

Store your configuration files (`.bashrc`, `.vimrc`, `.gitconfig`) in a git repo. Easy to replicate across machines.

### 4. Join the Community

**Linux communities:**

- r/linux, r/linuxquestions, r/Ubuntu on Reddit
- Ubuntu Forums: [ubuntuforums.org](https://ubuntuforums.org)
- Ask Ubuntu: [askubuntu.com](https://askubuntu.com)
- Linux Discord servers

**Ask questions.** Everyone was a beginner once. The community is generally helpful.

**Help others once you know more.** Teaching reinforces learning.

### 5. Keep a Learning Log

Document what you learn:

- Commands you discovered
- Problems you solved
- Configurations that worked

**Use a notes app, wiki, or blog.** You'll reference it constantly.

I can't count how many times I've searched my own notes for "how did I configure that thing last year?"

## Resources to Continue Learning

**Official documentation:**

- Ubuntu documentation: [help.ubuntu.com](https://help.ubuntu.com)
- Arch Wiki: [wiki.archlinux.org](https://wiki.archlinux.org) (applies to all Linux distros, excellent quality)

**Online courses:**

- Linux Journey: [linuxjourney.com](https://linuxjourney.com) (free, interactive)
- The Linux Command Line book: [http://linuxcommand.org/tlcl.php](http://linuxcommand.org/tlcl.php) (free ebook)
- edX and Coursera Linux courses

**Practice platforms:**

- OverTheWire: [overthewire.org](https://overthewire.org) (command-line challenges)
- Linux Survival: [linuxsurvival.com](https://linuxsurvival.com) (interactive tutorial)

**YouTube channels:**

- Learn Linux TV
- The Linux Experiment
- LearnLinux.tv
- NetworkChuck (DevOps-focused)

## Final Thoughts

**You've completed Day One.** You installed Linux, configured the basics, and you're ready to learn.

**The path from here is yours to choose.** Command-line mastery, system administration, DevOps, development, or just exploring - all are valuable.

**The most important thing:** Use Linux. Daily if possible. The more you use it, the more comfortable you become. Commands that seem arcane today will be second nature in a month.

**You will make mistakes.** You'll accidentally delete files. You'll break configurations. You'll spend hours debugging something trivial. That's not failure - that's learning. Every experienced Linux user has a folder full of broken systems and "I'll never do that again" stories.

**The Linux ecosystem is enormous.** You can't learn it all. Focus on what you need, learn as you go, and enjoy the journey.

**Most importantly:** Don't let perfect be the enemy of good. You don't need to understand everything before you start building. Jump in, break things, fix them, learn.

**Welcome to Linux.** You're at the beginning of a journey that thousands of us have taken before you. The community is here to help, the documentation is extensive, and the skills you're building are valuable.

Let's keep exploring.

---

## Quick Reference: Where to Go Next

| Your Goal | Start Here | Then Go To |
|-----------|-----------|------------|
| **General Linux skills** | [Level 1](../level_1/overview.md) | Continue through levels sequentially |
| **Linux certification** | [Level 1](../level_1/overview.md) | Levels 1-4 + certification study guides |
| **DevOps career** | [Level 1](../level_1/overview.md) + git | Docker, Ansible, cloud platforms |
| **Software development** | Dev environment setup | [Level 1](../level_1/overview.md), Level 2 |
| **Build a specific project** | Project setup | Learn skills as needed |
| **System administration** | [Level 1](../level_1/overview.md) | Levels 3-4, services, networking |
| **Just exploring** | [Level 1](../level_1/overview.md) | Follow your curiosity |

**Everyone starts at Level 1.** Master the basics, then branch out based on your interests.

The adventure starts now.
