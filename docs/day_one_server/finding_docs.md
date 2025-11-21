# Finding Documentation

You're on a server, you've explored around, and now you have questions:

- *"What application runs here?"*
- *"How do I deploy changes?"*
- *"Who do I contact if something breaks?"*

The answers exist somewhere. Your team has documentation — it might just be scattered across wikis, README files, and the brains of senior engineers.

**Let's find it.**

---

## Start on the Server Itself

Before digging through wikis, check if there's documentation right on the server.

### Check for README Files

Developers often leave breadcrumbs:

``` bash title="Find README Files"
find /var/www -name "README*" 2>/dev/null
find /opt -name "README*" 2>/dev/null
find /home -name "README*" 2>/dev/null
```

``` bash title="Read the README"
cat /var/www/app/README.md
```

### Check the MOTD (Message of the Day)

Some teams put important info in the login message:

``` bash title="View Login Message"
cat /etc/motd
```

You probably saw this when you logged in — it might contain server purpose, contact info, or important warnings.

### Look for Documentation Directories

``` bash title="Common Documentation Locations"
ls -la /opt/*/docs/ 2>/dev/null
ls -la /var/www/*/docs/ 2>/dev/null
ls -la /usr/local/share/doc/ 2>/dev/null
```

### Check for Deployment Scripts

Deployment scripts often explain how things work:

``` bash title="Find Deployment Scripts"
find / -name "deploy*" -type f 2>/dev/null | head -20
find / -name "*.sh" -path "*/scripts/*" 2>/dev/null | head -20
```

Read them (don't run them!) to understand the deployment process:

``` bash title="Read Deploy Script"
cat /opt/app/scripts/deploy.sh
```

---

## Find the Team Wiki

Almost every team has a wiki. The challenge is finding it.

### Ask These Questions

When you join a team or get access to a new server, ask:

1. **"Where's the documentation for this system?"**
2. **"Is there a runbook for common tasks?"**
3. **"What wiki/Confluence/Notion do you use?"**

### Common Wiki Platforms

Your team probably uses one of these:

| Platform | What to Search |
|----------|---------------|
| **Confluence** | Search for server hostname, application name |
| **Notion** | Check shared workspaces |
| **GitHub/GitLab Wiki** | Look in the repository for the app |
| **Google Docs** | Search your company Drive |
| **SharePoint** | Search the team site |
| **Internal Wiki** | Ask for the URL |

### Search Tips

Once you find the wiki, search for:

- Server hostname (`prod-web-01`)
- Application name
- "Runbook" + application name
- "Architecture" + application name
- "On-call" + application name

---

## Find the Code Repository

The code often has the best documentation.

### Check for Git on the Server

``` bash title="Find Git Repositories"
find / -name ".git" -type d 2>/dev/null | head -10
```

``` bash title="Check Git Remote"
cd /var/www/app
git remote -v
# origin  git@github.com:company/app.git (fetch)
```

Now you know where the code lives. Go read the repository's README, wiki, and docs folder.

### README Files in Repos

Most repos have documentation:

- `README.md` — Project overview
- `docs/` — Detailed documentation
- `CONTRIBUTING.md` — How to make changes
- `.env.example` — Configuration options
- `docker-compose.yml` — How things connect

---

## Find the Runbooks

Runbooks are step-by-step guides for common tasks. They're gold.

**Runbooks typically cover:**

- How to deploy
- How to rollback
- What to do when alerts fire
- How to restart services
- How to check health
- Who to escalate to

### Where Runbooks Live

- Team wiki (Confluence, Notion)
- Git repository (`/docs/runbooks/`)
- On-call documentation
- PagerDuty/OpsGenie notes

### Ask For Them

> "Is there a runbook for this application?"
> "What's the rollback procedure if something goes wrong?"
> "Where's the on-call documentation?"

---

## Find Who to Ask

Documentation is incomplete. People fill the gaps.

### Check Code Ownership

``` bash title="Git Blame - Who Wrote This?"
cd /var/www/app
git log --oneline -10
```

```
a1b2c3d Fix database connection timeout (Jane Smith)
e4f5g6h Update config for new API (Bob Johnson)
...
```

These are people who know this code.

### Check Git Blame

Who last modified a specific file?

``` bash title="Who Changed This File?"
git blame config/database.yml | head -20
```

### Find the On-Call

Most teams have an on-call rotation. Find out who's currently on-call:

- Check PagerDuty/OpsGenie
- Check Slack (there's usually an on-call channel)
- Ask: "Who's on-call for [application name]?"

### Team Slack Channels

Most applications have associated Slack channels:

- `#app-name` — General discussion
- `#app-name-alerts` — Automated alerts
- `#app-name-deploys` — Deployment notifications
- `#team-name` — The team that owns it

Search Slack for the server hostname or application name to find relevant channels.

---

## Documenting What You Learn

Here's a secret: **if you can't find documentation, you're the perfect person to write it.**

As you figure things out:

1. Take notes
2. Ask your team where to put documentation
3. Write up what you learned
4. Future-you (and teammates) will thank you

### What to Document

- How to access the server
- What the server does
- Where logs live
- Common commands you need
- Who to contact for help
- Troubleshooting steps you discovered

---

## The Questions Checklist

When you get access to a new server, get answers to these:

| Question | Why It Matters |
|----------|---------------|
| What application runs here? | Understand the purpose |
| Where's the code repository? | Find detailed docs, make changes |
| Where's the team wiki? | Find runbooks and context |
| What's the deployment process? | Know how changes go out |
| Who owns this application? | Know who to ask |
| What's the on-call rotation? | Know who to escalate to |
| Where are the logs? | Debug problems |
| What monitoring exists? | See dashboards and alerts |
| What's the rollback procedure? | Recover from mistakes |

---

## Quick Reference

### Finding Docs on the Server

``` bash title="Documentation Hunt"
# README files
find /var/www /opt /home -name "README*" 2>/dev/null

# Git repos
find / -name ".git" -type d 2>/dev/null | head -10

# Scripts that explain things
find / -name "*.sh" -path "*/scripts/*" 2>/dev/null | head -20

# Login message
cat /etc/motd
```

### Finding Docs Off the Server

| Source | What to Search For |
|--------|-------------------|
| Team wiki | Server hostname, app name |
| Git repo | README, docs/, wiki |
| Slack | `#app-name`, hostname |
| Monitoring | Dashboards with app name |

### Finding People

| Method | How |
|--------|-----|
| Git log | Who committed recently |
| Git blame | Who modified specific files |
| On-call schedule | PagerDuty/OpsGenie |
| Slack | App/team channels |

---

## Quick Recap

**Start on the server:**

- Look for README files
- Check the MOTD
- Find git repositories

**Find team resources:**

- Ask for wiki location
- Search for runbooks
- Find Slack channels

**Find people:**

- Check git history for recent contributors
- Find the on-call rotation
- Ask in team channels

**Give back:**

- Document what you learn
- Help the next person

---

## What's Next?

You know how to find documentation and who to ask. Now let's put it into practice with [Common First Tasks](first_tasks.md) — the actual things you'll probably be asked to do on your first day with a new server.

!!! tip "The Best Documentation Is a Conversation"
    Don't be afraid to ask questions. Every senior engineer was once the new person who didn't know where anything was. Most people are happy to help.
