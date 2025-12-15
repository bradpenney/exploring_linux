# Cloud Options

!!! quote "A Linux server in the cloud - access from anywhere"

## Why Cloud Linux?

You don't have spare hardware. Or maybe you do, but you want experience with cloud infrastructure that employers actually use. Or you want a Linux server accessible from anywhere - your laptop, your phone, a coffee shop.

**Cloud virtual machines are real Linux servers running in somebody else's datacenter.** You get root access, full control, and practical experience with how production systems actually work. Plus, multiple providers offer free tiers that are perfect for learning.

This isn't the same as a desktop Linux experience - you'll interact via SSH (command line only, no GUI). But that's exactly how you'd work with real servers in production environments. If you're preparing for DevOps, sysadmin, or cloud engineering roles, this is valuable experience.

## Cloud Free Tiers: What's Available

Several major cloud providers offer free tiers suitable for learning Linux:

| Provider | Free Offer | Specs | Duration | Best For |
|----------|-----------|-------|----------|----------|
| **Oracle Cloud** | Always Free tier | 2 VMs (ARM-based), 1-4 OCPUs, 6-24GB RAM | Permanent | Best free resources |
| **AWS** | Free tier | 1 t2.micro (1 vCPU, 1GB RAM) | 12 months | Industry standard, resume value |
| **Google Cloud** | Free tier | 1 e2-micro (0.25-2 vCPUs, 1GB RAM) | 3 months $300 credit, then permanent free | Google ecosystem |
| **Azure** | Free tier | 1 B1S (1 vCPU, 1GB RAM) | 12 months $200 credit | Microsoft ecosystem |
| **DigitalOcean** | $200 credit | Standard droplets | 60 days | Simple, developer-friendly |
| **Linode** | $100 credit | Standard instances | 60 days | Great documentation |

**My recommendations:**

- **Best for long-term learning:** Oracle Cloud (permanent free tier with generous resources)
- **Best for resume/career:** AWS (industry standard, most job postings mention it)
- **Best for beginners:** DigitalOcean (simplest interface, excellent tutorials)

## Option 1: Oracle Cloud (Recommended for Learning)

Oracle's Always Free tier is the most generous - permanent free VMs with surprising power.

### What You Get (Always Free)

- 2 AMD-based VMs (1/8 OCPU, 1GB RAM each) **OR** 4 ARM-based VMs (1 OCPU, 6GB RAM each)
- 200GB block storage
- 10GB object storage
- Generous network bandwidth

**The ARM VMs are incredible for a free tier** - 1 CPU core and 6GB RAM is more than enough for learning.

### Setup Steps

1. **Go to oracle.com/cloud/free**
2. **Create account**
   - Requires credit card (for verification - won't be charged)
   - Email verification
   - Phone verification

3. **Sign in to Oracle Cloud Console**

4. **Create a Compute Instance:**
   - Click "Create a VM instance"
   - **Name:** learning-linux (or whatever)
   - **Placement:** Leave default
   - **Image:** Canonical Ubuntu 24.04 (under "Change Image")
   - **Shape:** Change to "Ampere" (ARM) for better specs
     - VM.Standard.A1.Flex
     - 1 OCPU, 6GB RAM (adjust to your preference within free tier)
   - **Networking:** Create new Virtual Cloud Network (VCN) - auto-configured
   - **SSH Keys:** Upload your SSH public key or generate new keypair
     - **IMPORTANT:** Save the private key if generating - you'll need it to connect

5. **Click "Create"**

Wait 1-2 minutes for the instance to provision.

### Connect to Your Oracle VM

The console will show your instance's public IP address.

```bash title="SSH to Oracle Cloud instance"
ssh -i ~/path/to/private-key ubuntu@<PUBLIC_IP>
```

Replace `<PUBLIC_IP>` with your instance's IP.

First time connecting, type `yes` to accept the host key.

**You're in!** You have a free Linux server.

### Open Ports (Firewall Configuration)

Oracle blocks most ports by default. To open ports (e.g., for web server):

1. **In Cloud Console:** Networking → Virtual Cloud Networks
2. **Click your VCN** → Security Lists → Default Security List
3. **Add Ingress Rule:**
   - Source CIDR: 0.0.0.0/0
   - IP Protocol: TCP
   - Destination Port Range: 80,443
   - Click "Add Ingress Rule"

Also configure Ubuntu's firewall on the VM:

```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

## Option 2: AWS EC2 (Best for Resume Value)

Amazon Web Services is the industry standard. AWS experience looks great on resumes.

### What You Get (12-Month Free Tier)

- 750 hours/month of t2.micro instances (1 vCPU, 1GB RAM)
- 30GB EBS storage
- 15GB data transfer out

**Note:** Free tier is for first 12 months after signup. After that, instances cost money (unless you're careful to use only free-eligible services).

### Setup Steps

1. **Go to aws.amazon.com**
2. **Create AWS account**
   - Requires credit card
   - Phone verification
   - Choose "Personal" account type

3. **Sign in to AWS Console**

4. **Navigate to EC2:**
   - Services → Compute → EC2
   - Click "Launch Instance"

5. **Configure Instance:**
   - **Name:** my-linux-server
   - **Application and OS Images:** Ubuntu Server 24.04 LTS
   - **Instance type:** t2.micro (free tier eligible)
   - **Key pair:** Create new key pair
     - Type: RSA
     - Format: .pem
     - Name: my-key
     - **Download and save the .pem file**
   - **Network settings:** Allow SSH (port 22) from anywhere (0.0.0.0/0)
     - Can restrict to your IP for better security
   - **Configure storage:** 30GB gp3 (free tier eligible)
   - **Click "Launch Instance"**

Wait for instance state to show "Running".

### Connect to Your AWS Instance

Get the public IP from EC2 console.

```bash title="Set key permissions (required)"
chmod 400 ~/Downloads/my-key.pem
```

```bash title="SSH to AWS instance"
ssh -i ~/Downloads/my-key.pem ubuntu@<PUBLIC_IP>
```

### Open Additional Ports (Security Group)

To open ports for web server, etc.:

1. **EC2 Console** → Instances → Select your instance
2. **Security tab** → Click security group link
3. **Inbound rules** → Edit inbound rules
4. **Add rule:**
   - Type: HTTP (or Custom TCP)
   - Port: 80
   - Source: 0.0.0.0/0 (anywhere)
5. **Save rules**

### Important: Avoid Unexpected Charges

**Free tier limits:**

- 750 hours/month = 1 instance running 24/7
- If you have 2 instances running simultaneously, you'll use 1440 hours/month → charges!

**To avoid charges:**

- **Stop instances when not using** (EC2 Console → Instance State → Stop)
  - Stopped instances don't count toward 750 hours
- **Monitor billing:** AWS Console → Billing Dashboard
- **Set up billing alerts:** Receive email if charges exceed $0

## Option 3: Google Cloud Platform

Google's free tier includes 3 months of $300 credit plus always-free resources.

### What You Get

- $300 credit for 90 days (use on anything)
- After credit expires: 1 e2-micro instance permanently free (US regions only)
  - 0.25-2 vCPUs, 1GB RAM
  - 30GB storage

### Setup Steps

1. **Go to cloud.google.com**
2. **Start free trial**
   - Google account required
   - Credit card required (won't be charged during trial)

3. **Go to Compute Engine** → VM Instances

4. **Create instance:**
   - **Name:** my-linux-vm
   - **Region:** us-east1, us-west1, or us-central1 (required for always-free)
   - **Machine type:** e2-micro (free tier eligible)
   - **Boot disk:** Ubuntu 24.04 LTS
   - **Firewall:** Allow HTTP traffic (if planning web server)
   - **Click "Create"**

### Connect to GCP Instance

Google Cloud has a built-in SSH option:

- **In GCP Console:** Click "SSH" button next to your instance
- Browser-based SSH terminal opens

Or use local SSH:

```bash
gcloud compute ssh my-linux-vm --zone=us-east1-b
```

(Requires installing Google Cloud SDK)

## Option 4: Azure

Microsoft Azure offers $200 credit for 30 days, then 12 months of free services.

### What You Get

- $200 credit for 30 days
- 12 months of free services including:
  - B1S Linux VM (1 vCPU, 1GB RAM)
  - 64GB SSD storage

### Setup Steps

1. **Go to azure.microsoft.com/free**
2. **Start free**
   - Microsoft account required
   - Credit card for verification

3. **Azure Portal** → Virtual Machines → Create

4. **Configure:**
   - **Subscription:** Free trial
   - **Resource group:** Create new
   - **Name:** linuxVM
   - **Region:** Choose nearest
   - **Image:** Ubuntu Server 24.04 LTS
   - **Size:** B1s (free tier)
   - **Authentication:** SSH public key
   - **Inbound ports:** SSH (22)
   - **Review + Create**

### Connect

```bash
ssh -i ~/.ssh/id_rsa azureuser@<PUBLIC_IP>
```

## Option 5: DigitalOcean (Simplest)

DigitalOcean isn't free long-term, but $200 credit gives you 60 days of learning time, and their interface is the simplest.

### What You Get

- $200 credit for 60 days (via referral links)
- Droplets (VMs) start at $6/month ($0.009/hour)
- Basic droplet: 1 vCPU, 1GB RAM, 25GB SSD

### Setup Steps

1. **Sign up:** digitalocean.com (search for referral links for $200 credit)
2. **Create Droplet:**
   - **Choose an image:** Ubuntu 24.04 LTS
   - **Choose a plan:** Basic ($6/month)
   - **CPU options:** Regular (1GB RAM)
   - **Authentication:** SSH key (add yours or create new)
   - **Hostname:** my-linux-server
   - **Create Droplet**

Provisions in under 60 seconds.

### Connect

```bash
ssh root@<DROPLET_IP>
```

Note: DigitalOcean droplets default to root access. Create a regular user immediately for security:

```bash
adduser yourusername
usermod -aG sudo yourusername
```

## Cloud Best Practices for Learning

### 1. Shut Down When Not Using

Most cloud providers charge for running instances. Stop/terminate when you're done for the day.

**Oracle Cloud Always Free:** Can run 24/7 without charges.

**AWS/Azure/GCP:** Stop instances when not in use.

### 2. Use SSH Keys, Not Passwords

All cloud providers support (and prefer) SSH key authentication. More secure than passwords.

### 3. Restrict SSH Access

Don't allow SSH from 0.0.0.0/0 (entire internet) if you can avoid it. Restrict to your home IP:

```bash
# In security group / firewall rules:
Source: YOUR_HOME_IP/32
```

### 4. Keep Systems Updated

```bash title="Weekly update routine"
sudo apt update && sudo apt upgrade -y
```

Enable unattended security updates:

```bash
sudo apt install unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
```

### 5. Monitor Costs (AWS/Azure/GCP)

Set up billing alerts in provider console. Get notified if costs exceed $0.

### 6. Take Snapshots Before Major Changes

Create snapshots/images before installing new software or making configuration changes. Easy rollback if something breaks.

## What to Do With Your Cloud Linux Server

**Learning projects perfect for cloud VMs:**

- **Web server:** Apache/Nginx + static site
- **Blog:** WordPress, Ghost, Hugo
- **VPN:** WireGuard or OpenVPN
- **Personal cloud:** Nextcloud
- **Development server:** Git server, CI/CD
- **Database practice:** MySQL, PostgreSQL, MongoDB
- **Containerization:** Docker, Kubernetes (on larger instances)
- **Monitoring:** Grafana, Prometheus
- **Reverse proxy:** Traefik, Caddy

## What's Next?

Your cloud Linux server is running. You've SSHed in. You're looking at a command prompt.

**Now what?**

1. **Secure it:** Follow **[Post-Install Essentials](post_install.md)** for initial configuration
2. **Learn the command line:** Head to **[Level 1: Everyday Navigation](../level_1/overview.md)**
3. **Build something:** Deploy a web server, set up a database, create a project
4. **Practice server administration:** User management, log monitoring, service configuration

## Key Takeaways

- **Oracle Cloud offers the best permanent free tier** - 4 ARM VMs with generous resources
- **AWS experience is valuable for resumes** - industry standard, 12-month free tier
- **Cloud VMs are CLI-only** - no desktop environment, all SSH access
- **Stop instances when not in use** - avoid unexpected charges (except Oracle Always Free)
- **SSH key authentication is standard** - more secure than passwords
- **Perfect for learning server administration** - exactly how production systems work

Cloud Linux servers aren't just for learning - they're how most of the internet actually runs. When you deploy to production later in your career, it'll look a lot like this: an Ubuntu server in the cloud, accessed via SSH, running services.

You're not just learning Linux - you're learning how real infrastructure works.

Let's keep building.
