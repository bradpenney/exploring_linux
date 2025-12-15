# Directory Navigation Tips & Tricks

!!! quote "Work smarter, not harder"

## Beyond the Basics

You know `cd`, `ls`, and `pwd`. You can navigate the filesystem. But you're typing too much, moving too slowly, and not using the powerful shortcuts available.

**Efficient navigation isn't about memorizing more commands** - it's about leveraging the ones you know with smart techniques, aliases, and shell features that make you faster.

This guide covers the productivity tricks that separate beginners from efficient Linux users.

## Aliases: Your Custom Commands

An alias is a shortcut - a custom command name that runs something else.

### Creating Temporary Aliases

```bash title="Create an alias for this session only"
alias ll='ls -lah'
```

Now `ll` runs `ls -lah` (long format, human-readable, show hidden files).

```bash
ll
# total 48K
# drwxr-xr-x 12 brad brad 4.0K Dec 14 10:30 .
# drwxr-xr-x  3 root root 4.0K Nov 15 08:45 ..
# -rw-------  1 brad brad  15K Dec 14 09:22 .bash_history
# ...
```

**This lasts until you close the terminal.**

### Making Aliases Permanent

Add them to `~/.bashrc` (or `~/.zshrc` if using Zsh):

```bash title="Edit your bashrc"
nano ~/.bashrc
```

Add at the end:

```bash title="Useful aliases"
# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Listing
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'

# Common directories
alias projects='cd ~/projects'
alias docs='cd ~/Documents'
alias dl='cd ~/Downloads'

# Safety
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Shortcuts
alias h='history'
alias c='clear'
alias e='exit'
```

Save and exit (Ctrl+O, Enter, Ctrl+X).

**Reload bashrc:**

```bash
source ~/.bashrc
```

Now your aliases work in every new terminal.

### Useful Alias Patterns

**Go up multiple directories:**

```bash
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
```

Now `...` takes you up two levels.

**Quick access to frequent directories:**

```bash
alias proj='cd ~/projects/current-project'
alias web='cd /var/www/html'
alias logs='cd /var/log && ll'
```

**Enhanced commands:**

```bash
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias df='df -h'          # Human-readable disk space
alias du='du -h'          # Human-readable directory sizes
alias free='free -h'      # Human-readable memory info
```

**Time-savers:**

```bash
alias update='sudo apt update && sudo apt upgrade -y'
alias install='sudo apt install'
alias search='apt search'
```

**Git shortcuts (if you use Git):**

```bash
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'
```

### View and Remove Aliases

**List all aliases:**

```bash
alias
```

**Remove an alias (for this session):**

```bash
unalias ll
```

**Run command without alias:**

If you have `alias rm='rm -i'` but want to run actual `rm` without confirmation:

```bash
\rm file.txt
```

The backslash bypasses the alias.

## The Directory Stack: `pushd` and `popd`

When working with multiple directories, `pushd` and `popd` let you save and return to locations.

### How It Works

**`pushd` - Push current directory onto stack and change to new directory:**

```bash
pwd
# /home/brad

pushd /var/log
pwd
# /var/log

pushd /etc
pwd
# /etc
```

Now the stack looks like:
```
/etc (current)
/var/log
/home/brad
```

**`popd` - Pop directory from stack and return to it:**

```bash
popd
pwd
# /var/log

popd
pwd
# /home/brad
```

### Practical Use

Working on a project but need to check logs:

```bash
cd ~/projects/my-app     # Working here
pushd /var/log           # Save location, go to logs
tail syslog              # Check logs
popd                     # Return to project
```

**View the directory stack:**

```bash
dirs -v
```

**Output:**
```
 0  /etc
 1  /var/log
 2  /home/brad
```

**Jump to specific position in stack:**

```bash
pushd +1    # Go to position 1 (/var/log)
```

## Smart Tab Completion

You know Tab completes filenames. But there's more.

### Complete Directories Only

When typing `cd`, Tab completion shows only directories:

```bash
cd Do<TAB>
# Completes to: cd Documents/ or shows: Documents/ Downloads/
```

### Complete Hostnames for SSH

```bash
ssh user@<TAB><TAB>
```

Shows hosts from `~/.ssh/config` and `~/.ssh/known_hosts`.

### Complete Package Names

```bash
sudo apt install fire<TAB>
# Completes to: firefox or shows: firefox firefox-esr
```

### Complete Command Options

Some shells (Zsh with oh-my-zsh, or bash-completion package) complete command flags:

```bash
ls -<TAB><TAB>
# Shows: -a -A -l -h -r -t -S...
```

Install bash completion:

```bash
sudo apt install bash-completion
```

Add to `~/.bashrc`:

```bash
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi
```

## Environment Variables for Navigation

### CDPATH: Search Paths for `cd`

`CDPATH` tells `cd` where to look for directories:

```bash title="Add to ~/.bashrc"
export CDPATH=.:~:~/projects
```

Now `cd website` works from anywhere if `~/projects/website` exists:

```bash
pwd
# /var/log

cd website
# bash searches: ./website, ~/website, ~/projects/website
# Found! Changes to ~/projects/website
```

**View current CDPATH:**

```bash
echo $CDPATH
```

### PS1: Custom Prompt

`PS1` controls your command prompt. Make it show useful info:

```bash title="Add to ~/.bashrc"
# Show username, hostname, current directory
PS1='\u@\h:\w\$ '
```

**Output:**
```
brad@ubuntu:~/projects$
```

**Show current git branch (requires git prompt script):**

```bash
# Colorful prompt with git branch
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$(__git_ps1 " (%s)")\$ '
```

Search "bash PS1 generator" for tools to customize visually.

## Keyboard Shortcuts for Navigation

These work in bash/zsh. You don't need to learn them all at once, but picking up a few will dramatically speed up your workflow.

| Shortcut      | What it Does                                                                 |
| ------------- | ---------------------------------------------------------------------------- |
| `TAB`       | Autocompletes a partially typed command. If there’s more than one match, Bash shows you the options. |
| `↑ / ↓`     | Scroll back/forward through your command history. |
| `Ctrl+E`    | Jump to the **end** of the current line. (e = end) |
| `Ctrl+A`    | Jump to the **start** of the current line. (a = alphabet’s start) |
| `Ctrl+U`    | Delete everything from the cursor **back to the start** of the line. |
| `Ctrl+K`    | Delete everything from the cursor **to the end** of the line. |
| `Ctrl+W`    | Delete the word just before the cursor. |
| `Ctrl+Y`    | Paste back (yank) the last thing you deleted with `Ctrl+u`, `Ctrl+k`, or `Ctrl+w`. |
| `Ctrl+L`    | Clear the screen (like the `clear` command). |
| `Ctrl+C`    | Cancel/kill the currently running command or process. |
| `Ctrl+Z`    | Pause the current job (suspends it in the background). |
| `fg`        | Resume the most recent job that was paused with `Ctrl+z`. |
| `bg`        | Resume the paused job, but keep it running in the background. |
| `Ctrl+D`    | Log out of the current shell (or send an EOF if in a prompt). |
| `Ctrl+R`    | Reverse search through your command history. Type part of a command and Bash will find it. (Game-changer!) |
| `!!`        | Run the last command again. (`sudo !!` is a classic trick.) |

---

### In-depth Examples

**Movement:**

- **Ctrl+A** - Move to beginning of line
- **Ctrl+E** - Move to end of line
- **Ctrl+U** - Delete from cursor to beginning
- **Ctrl+K** - Delete from cursor to end
- **Ctrl+W** - Delete word before cursor
- **Alt+B** - Move backward one word
- **Alt+F** - Move forward one word

**History:**

- **Ctrl+R** - Reverse search history (type to search, Enter to execute)
- **Ctrl+P** or **Up** - Previous command
- **Ctrl+N** or **Down** - Next command
- **!!** - Repeat last command
- **!$** - Last argument of previous command

**Examples:**

```bash
ls /var/log/apache2
cd !$
# Same as: cd /var/log/apache2
```

```bash
sudo apt update
sudo !!
# Same as: sudo apt update (runs previous command with sudo)
```

**Screen:**

- **Ctrl+L** - Clear screen (like `clear` command)

## History Search and Reuse

### Reverse Search

**Ctrl+R** opens reverse search:

```bash
# Press Ctrl+R
(reverse-i-search)`':
```

Type part of a previous command:

```
(reverse-i-search)`ssh': ssh user@server.com
```

Press Enter to execute or Ctrl+R again to find older matches.

### History Commands

**View command history:**

```bash
history
```

**Output:**
```
  1  ls
  2  cd Documents
  3  vim notes.txt
  ...
```

**Run command by number:**

```bash
!123
```

Runs command #123 from history.

**Run most recent command starting with string:**

```bash
!ssh
```

Runs most recent command starting with "ssh".

**Search history with grep:**

```bash
history | grep "apt install"
```

Shows all install commands you've run.

### History Configuration

```bash title="Add to ~/.bashrc"
# Don't store duplicates
export HISTCONTROL=ignoredups

# Increase history size
export HISTSIZE=10000
export HISTFILESIZE=20000

# Append to history file, don't overwrite
shopt -s histappend

# Save multi-line commands as one line
shopt -s cmdhist
```

## Directory Bookmarks with Tools

### autojump

`autojump` learns your most-used directories and lets you jump to them quickly.

```bash title="Install autojump"
sudo apt install autojump
```

Add to `~/.bashrc`:

```bash
. /usr/share/autojump/autojump.sh
```

**Usage:**

```bash
# Navigate normally a few times
cd ~/projects/website
cd ~/projects/website
cd ~/projects/website

# Now just:
j website
# Jumps to ~/projects/website
```

It tracks frequency and recency, jumping to the most likely match.

### z (Alternative to autojump)

Similar to autojump:

```bash title="Install z"
git clone https://github.com/rupa/z.git ~/z
echo '. ~/z/z.sh' >> ~/.bashrc
source ~/.bashrc
```

**Usage:**

```bash
z website    # Jumps to most frequently/recently used dir matching "website"
```

### Midnight Commander (mc)

A file manager TUI (text user interface):

```bash
sudo apt install mc
mc
```

Navigate with arrow keys, F10 to quit.

Some people love it; others prefer pure command line. Try it and see.

## Advanced ls Tricks

**Sort by size (largest first):**

```bash
ls -lhS
```

**Sort by time (newest first):**

```bash
ls -lht
```

**Reverse any sort:**

```bash
ls -lhtr   # Oldest first
```

**List only directories:**

```bash
ls -d */
```

**List files recursively:**

```bash
ls -R
```

Better: use `tree`:

```bash
sudo apt install tree
tree
```

**Output:**
```
.
├── dir1
│   ├── file1.txt
│   └── file2.txt
├── dir2
│   └── subdir
│       └── file3.txt
└── file.txt
```

**Count files in directory:**

```bash
ls -1 | wc -l
```

`-1` forces one file per line, `wc -l` counts lines.

## Fast File Finding

**Find files by name:**

```bash
find . -name "*.txt"
```

**Find directories:**

```bash
find . -type d -name "config"
```

**Find files modified in last 7 days:**

```bash
find . -type f -mtime -7
```

**Find and do something with results:**

```bash
find . -name "*.log" -exec rm {} \;
```

Finds all .log files and deletes them.

**Faster alternative - `locate`:**

```bash
sudo apt install mlocate
sudo updatedb        # Build file database
locate filename.txt  # Search database
```

`locate` is much faster than `find` but database needs periodic updates.

## Practical Workflows

### Workflow 1: Project Switching

```bash title="Add to ~/.bashrc"
alias proj='cd ~/projects'
alias p1='cd ~/projects/project1'
alias p2='cd ~/projects/project2'
alias p3='cd ~/projects/project3'
```

Now switching projects is instant: `p1`, `p2`, `p3`.

### Workflow 2: Log Monitoring While Working

```bash
# Save current location, go check logs
pushd /var/log
tail -f syslog

# Ctrl+C to stop
popd    # Return to work directory
```

### Workflow 3: Multi-Location Work

```bash
cd ~/projects/frontend
pushd ~/projects/backend
pushd ~/projects/database

# Now at database
popd   # Go to backend
popd   # Go to frontend
```

### Workflow 4: Quick Cleanup

```bash title="Add to ~/.bashrc"
alias cleanup='cd ~/Downloads && rm *.tmp && cd -'
```

Deletes temp files from Downloads, returns to previous directory.

## Common Productivity Patterns

**Check, then act:**

```bash
ls *.log && rm *.log
```

Only deletes if files exist.

**Create and enter directory:**

```bash
mkcd() {
    mkdir -p "$1" && cd "$1"
}
```

Add to `~/.bashrc`. Now:

```bash
mkcd new-project
# Creates and enters new-project/
```

**Go up and list:**

```bash
alias ..='cd .. && ls'
```

**Quick navigation back:**

```bash
alias back='cd $OLDPWD'
```

`$OLDPWD` is previous directory (same as `cd -`).

## Tips for Speed

1. **Use aliases for common paths** - Don't type `/var/log/apache2` every time
2. **Use Tab completion religiously** - Let the shell do the typing
3. **Use Ctrl+R for history** - Don't retype commands
4. **Use `pushd`/`popd` for multi-location work** - Faster than `cd` back and forth
5. **Set CDPATH for project directories** - `cd website` from anywhere
6. **Learn keyboard shortcuts** - Ctrl+A, Ctrl+E, Ctrl+U, Ctrl+K
7. **Use `z` or `autojump`** - Navigate by frequency, not full paths

## Key Takeaways

- **Aliases save typing** - Create shortcuts for frequent commands
- **`pushd`/`popd` manage directory stack** - Work in multiple locations efficiently
- **Tab completion is your friend** - Use it constantly
- **CDPATH expands search paths** - Jump to project dirs from anywhere
- **Ctrl+R searches history** - Find and rerun commands quickly
- **`!$` reuses last argument** - Common pattern for navigating then acting
- **Tools like `z` and `autojump`** - Jump to frequent directories instantly
- **Custom functions in `~/.bashrc`** - Automate repetitive workflows

Efficient navigation isn't about knowing exotic commands - it's about using basic commands smartly with aliases, shortcuts, and shell features.

**The goal:** Spend less time navigating, more time working.

These techniques compound. Each one saves seconds. Over weeks and months, those seconds become hours. You navigate faster, work faster, think faster.

Let's keep building skills.
