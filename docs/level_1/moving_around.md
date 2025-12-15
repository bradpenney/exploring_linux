# Moving Around

!!! quote "Three commands you'll type thousands of times"

## The Command Line Isn't Scary

When you first see a terminal with a blinking cursor, it can feel intimidating. No mouse. No icons to click. Just a prompt waiting for you to know what to type.

**Here's the thing: navigating Linux directories is simpler than navigating Windows Explorer or Mac Finder.** Once you know three commands - `ls`, `cd`, and `pwd` - you can get anywhere.

These are the commands you'll type so often they'll become muscle memory. Within a week, you'll navigate faster via command line than you ever did clicking through folders.

## Where Am I? The `pwd` Command

Before you can go somewhere, you need to know where you are.

```bash title="Print working directory"
pwd
```

**Output:**
```
/home/brad
```

`pwd` stands for "print working directory." It shows your current location in the filesystem.

**Every user has a home directory:**

- Yours is `/home/yourusername`
- Root user's home is `/root`
- When you open a terminal, you start in your home directory

**The tilde (`~`) is shorthand for your home directory:**

```bash
pwd
# /home/brad

cd /etc
pwd
# /etc

cd ~
pwd
# /home/brad
```

**Why this matters:**

Many commands operate on your current directory. If you try to copy a file and it says "file not found," you're probably in the wrong directory. `pwd` tells you where you are.

## What's Here? The `ls` Command

You know where you are. Now, what's in this directory?

```bash title="List directory contents"
ls
```

**Output:**
```
Desktop  Documents  Downloads  Music  Pictures  Videos
```

That's the basic list - just names.

### Useful `ls` Options

**List with details:**

```bash title="Long listing format"
ls -l
```

**Output:**
```
drwxr-xr-x 2 brad brad 4096 Dec 14 10:30 Desktop
drwxr-xr-x 5 brad brad 4096 Dec 13 15:22 Documents
drwxr-xr-x 2 brad brad 4096 Dec 14 09:15 Downloads
```

This shows:
- Permissions (`drwxr-xr-x`)
- Number of links
- Owner and group
- Size in bytes
- Modification date/time
- Name

**List all files (including hidden):**

```bash title="Show hidden files"
ls -a
```

**Output:**
```
.  ..  .bashrc  .profile  Desktop  Documents  Downloads
```

Files starting with `.` are hidden. Your shell configuration (`.bashrc`), SSH keys (`.ssh/`), git config (`.gitconfig`) - all hidden by default.

**Combine options:**

```bash title="Long format with hidden files"
ls -la
```

Or:

```bash title="Same thing, different syntax"
ls -l -a
```

**Human-readable file sizes:**

```bash title="Use KB, MB, GB instead of bytes"
ls -lh
```

**Output:**
```
drwxr-xr-x 2 brad brad 4.0K Dec 14 10:30 Desktop
drwxr-xr-x 5 brad brad 4.0K Dec 13 15:22 Documents
-rw-r--r-- 1 brad brad 2.5M Dec 12 08:45 large-file.txt
```

Much easier to read than `2621440` bytes.

**Sort by modification time (newest first):**

```bash title="Sort by time, newest on top"
ls -lt
```

**Reverse sort (oldest first):**

```bash title="Reverse order"
ls -ltr
```

Useful for finding old files at the top.

**List a specific directory without changing to it:**

```bash title="List contents of /etc"
ls /etc
```

```bash title="List /var/log with details"
ls -l /var/log
```

### My Most-Used `ls` Alias

Most Linux users create an alias for their favorite `ls` combination:

```bash title="Add to ~/.bashrc"
alias ll='ls -lah'
```

Now `ll` gives you long format, human-readable sizes, and shows hidden files. I use this dozens of times a day.

## Going Places: The `cd` Command

`cd` stands for "change directory." It's how you move around the filesystem.

### Basic Navigation

**Go to a specific directory:**

```bash title="Change to Documents directory"
cd Documents
```

Now `pwd` shows `/home/brad/Documents`.

**Use absolute paths (starting from root):**

```bash title="Absolute path"
cd /var/log
```

Doesn't matter where you are - this always goes to `/var/log`.

**Use relative paths (from current location):**

```bash title="Relative path"
cd Documents/projects
```

This works if `Documents/` exists in your current directory.

### Special Directory Shortcuts

**Go home:**

```bash title="Return to home directory"
cd
```

Or:

```bash
cd ~
```

No arguments to `cd` means "go home."

**Go up one directory:**

```bash title="Go to parent directory"
cd ..
```

If you're in `/home/brad/Documents`, `cd ..` takes you to `/home/brad`.

**Go up two directories:**

```bash title="Go up two levels"
cd ../..
```

From `/home/brad/Documents/projects`, this takes you to `/home/brad`.

**Go to previous directory:**

```bash title="Toggle between two directories"
cd -
```

This switches between your current directory and the last directory you were in. Super useful when working in two locations.

**Example:**
```bash
pwd
# /home/brad/projects

cd /var/log
pwd
# /var/log

cd -
# /home/brad/projects

cd -
# /var/log
```

**Go to root directory:**

```bash title="Go to filesystem root"
cd /
```

This is the top of the filesystem - everything lives under `/`.

### Path Shortcuts

**Tilde (`~`) = home directory:**

```bash
cd ~/Documents
# Same as: cd /home/brad/Documents
```

**Dot (`.`) = current directory:**

Usually used with commands rather than `cd`:

```bash
cp /etc/hosts .  # Copy to current directory
```

**Double dot (`..`) = parent directory:**

```bash
cd ..  # Go up one level
```

**Dash (`-`) = previous directory:**

```bash
cd -  # Go to last directory
```

## Putting It All Together

Here's a typical navigation workflow:

```bash title="Real-world navigation example"
# Where am I?
pwd
# /home/brad

# What's here?
ls
# Desktop  Documents  Downloads

# Go to Documents
cd Documents

# Where am I now?
pwd
# /home/brad/Documents

# What's in here?
ls -l
# drwxr-xr-x 2 brad brad 4096 Dec 14 projects
# -rw-r--r-- 1 brad brad 2048 Dec 13 notes.txt

# Go into projects
cd projects

# Go back up to Documents
cd ..

# Go back up to home
cd ..

# Or just:
cd

# Check I'm home
pwd
# /home/brad
```

## Tab Completion (Your Secret Weapon)

**Don't type full directory names.** Use Tab completion.

**Example:**

```bash
cd Doc<TAB>
```

Press Tab after typing `Doc`, and the shell completes it to `Documents/`.

**If multiple matches exist:**

```bash
cd D<TAB><TAB>
```

Press Tab twice to see all options starting with `D`:

```
Desktop/  Documents/  Downloads/
```

Type more characters to narrow it down:

```bash
cd Do<TAB><TAB>
Documents/  Downloads/

cd Dow<TAB>
# Completes to: cd Downloads/
```

**This works for files too:**

```bash
cat my-long-filename<TAB>
```

**Tab completion saves you from typos, shows you what's available, and makes navigation fast.**

## Common Navigation Patterns

### Navigating Long Paths

```bash title="Multi-level navigation"
cd /var/log/apache2/
```

Or step-by-step:

```bash
cd /var
ls
cd log
ls
cd apache2
```

Use `pwd` frequently when learning to reinforce where you are.

### Working in Multiple Directories

Use `cd -` to toggle:

```bash
cd ~/projects/website
# Edit files...

cd /etc/nginx
# Check config...

cd -
# Back to ~/projects/website

cd -
# Back to /etc/nginx
```

### Exploring Unknown Directories

```bash title="Explore /etc"
cd /etc
ls
# Lots of files... what's in apache2?

ls apache2
# See contents without changing directory

cd apache2
ls -lh
# Now I'm in there and can see details
```

## Common Mistakes and How to Fix Them

### "No such file or directory"

```bash
cd document
# bash: cd: document: No such file or directory
```

**Possible causes:**

1. **Typo:** Linux is case-sensitive. `Document` ≠ `document`
2. **Wrong location:** File doesn't exist in current directory
3. **Need quotes:** Directory name has spaces

**Check what's actually there:**

```bash
ls
# Desktop  Documents  Downloads
# Aha, it's "Documents", not "document"

cd Documents
```

### Directory Names with Spaces

```bash
cd My Documents
# bash: cd: My: No such file or directory
```

**Linux interprets this as:** `cd` to "My", ignore "Documents"

**Fix: Use quotes:**

```bash
cd "My Documents"
```

**Or escape the space:**

```bash
cd My\ Documents
```

**Or use Tab completion** (automatically handles spaces):

```bash
cd My<TAB>
# Completes to: cd My\ Documents/
```

### "Permission denied"

```bash
cd /root
# bash: cd: /root: Permission denied
```

You don't have permission to access that directory (in this case, root's home directory).

**Fix:** Use `sudo` if you actually need access (rare), or navigate elsewhere.

## Practice Exercises

Try these to build muscle memory:

**Exercise 1: Home and back**

```bash
cd /var/log    # Go somewhere
pwd            # Check location
cd             # Return home
pwd            # Confirm you're home
```

**Exercise 2: Relative navigation**

```bash
cd /usr
cd bin        # Relative: go to /usr/bin
cd ..         # Up to /usr
cd ../var     # Up to /, then into var
pwd           # Should show /var
```

**Exercise 3: Toggle directories**

```bash
cd ~/Documents
cd /etc
cd -          # Back to Documents
cd -          # Back to /etc
cd -          # Back to Documents
```

**Exercise 4: Explore your home**

```bash
cd
ls -la        # See all files, including hidden
cd .ssh       # If it exists
ls -l         # See your SSH keys
cd ..         # Back to home
```

**Exercise 5: Use Tab completion**

```bash
cd /u<TAB>/l<TAB>/py<TAB>
# Should complete to: /usr/local/python or similar
```

## Pro Tips

**1. Create an alias for going to frequent directories:**

```bash title="Add to ~/.bashrc"
alias proj='cd ~/projects'
alias web='cd ~/projects/website'
```

Now `proj` instantly takes you to your projects directory.

**2. Use `pushd` and `popd` for directory stack:**

```bash
pushd /var/log    # Save current dir and go to /var/log
pushd /etc        # Save and go to /etc
popd              # Return to /var/log
popd              # Return to original directory
```

Advanced, but useful when working with multiple directories.

**3. The `CDPATH` variable:**

Set directories that `cd` searches:

```bash
export CDPATH=.:~:~/projects
```

Now `cd website` works from anywhere if `~/projects/website` exists.

**4. Use `ls` before `cd`:**

Get in the habit:

```bash
ls /var/log    # See what's there
cd /var/log    # Now go there
```

Prevents "no such directory" errors.

## Key Takeaways

- **`pwd`** - Where am I?
- **`ls`** - What's here?
- **`cd`** - Take me there
- **Tab completion** - Press Tab to complete names
- **`cd` with no arguments** - Go home
- **`cd ..`** - Go up one directory
- **`cd -`** - Go to previous directory
- **`~`** - Shortcut for home directory
- **Linux is case-sensitive** - `Documents` ≠ `documents`
- **Use quotes for spaces** - `cd "My Directory"`

These three commands - `pwd`, `ls`, `cd` - are your foundation. Everything else builds on this.

**You'll use them thousands of times.** The first hundred will feel slow. The second hundred, you'll speed up. By the thousandth time, you won't even think about it.

Navigation becomes second nature. Let's keep building.
