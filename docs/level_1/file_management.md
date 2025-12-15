# File Management

!!! quote "Create, copy, move, delete - the essentials"

## Beyond Just Looking

You can navigate directories and list files. Great. But eventually, you need to actually *do* something - create a folder, copy a file, move things around, delete what you don't need.

**Five commands handle 90% of file management:**

- `mkdir` - Make directories
- `rmdir` - Remove empty directories
- `cp` - Copy files and directories
- `mv` - Move (or rename) files and directories
- `rm` - Remove (delete) files and directories

These aren't complicated. But they're powerful, especially `rm` - which has no undo button.

Let's learn to use them safely and effectively.

## Creating Directories: `mkdir`

`mkdir` stands for "make directory."

```bash title="Create a single directory"
mkdir projects
```

Now you have a `projects/` directory in your current location.

```bash title="Verify it exists"
ls
# ... projects ...
```

### Create Multiple Directories

```bash title="Create several directories at once"
mkdir documents photos videos
```

```bash title="Verify"
ls
# documents  photos  projects  videos
```

### Create Nested Directories

What if you want `projects/website/css/`?

**This fails:**

```bash
mkdir projects/website/css
# mkdir: cannot create directory 'projects/website/css': No such file or directory
```

Why? Because `projects/` and `projects/website/` don't exist yet.

**Use `-p` (parents) to create all necessary parent directories:**

```bash title="Create nested directories"
mkdir -p projects/website/css
```

This creates:
- `projects/`
- `projects/website/`
- `projects/website/css/`

**Verify:**

```bash
ls -R projects
# projects/:
# website
#
# projects/website:
# css
#
# projects/website/css:
```

The `-p` flag is one you'll use constantly.

### Practical Examples

```bash title="Set up a project structure"
mkdir -p ~/projects/my-app/{src,tests,docs,config}
```

This creates:
```
projects/
└── my-app/
    ├── src/
    ├── tests/
    ├── docs/
    └── config/
```

The `{src,tests,docs,config}` syntax is called **brace expansion** - it creates multiple directories from one command.

```bash title="Create dated backup directories"
mkdir -p ~/backups/2024/{01,02,03,04,05,06,07,08,09,10,11,12}
```

Creates directories for each month.

## Removing Empty Directories: `rmdir`

`rmdir` removes directories - but **only if they're empty**.

```bash title="Remove an empty directory"
rmdir old-stuff
```

**If the directory has files:**

```bash
rmdir projects
# rmdir: failed to remove 'projects': Directory not empty
```

`rmdir` is safe - it won't delete directories with content.

**To remove non-empty directories, use `rm -r`** (covered later).

## Copying Files: `cp`

`cp` copies files and directories.

**Basic syntax:**

```
cp source destination
```

### Copy a Single File

```bash title="Copy file to same directory with new name"
cp resume.txt resume-backup.txt
```

Now you have two files: `resume.txt` and `resume-backup.txt`.

```bash title="Copy file to different directory"
cp resume.txt ~/documents/
```

This copies `resume.txt` into the `documents/` directory, keeping the same name.

```bash title="Copy and rename"
cp resume.txt ~/documents/my-resume.txt
```

Copies to `documents/` and renames it.

### Copy Multiple Files

```bash title="Copy several files to a directory"
cp file1.txt file2.txt file3.txt ~/documents/
```

**Last argument must be a directory** when copying multiple files.

### Copy with Wildcards

```bash title="Copy all .txt files"
cp *.txt ~/documents/
```

```bash title="Copy all files starting with 'report'"
cp report* ~/backups/
```

### Copy Directories (Recursive)

To copy a directory and its contents, use `-r` (recursive):

```bash title="Copy entire directory"
cp -r old-project new-project
```

This copies `old-project/` and everything in it to `new-project/`.

```bash title="Copy directory to different location"
cp -r ~/projects/website ~/backups/
```

### Useful `cp` Options

**Preserve attributes (permissions, timestamps):**

```bash title="Copy and preserve metadata"
cp -p important.conf important.conf.bak
```

**Verbose output (show what's being copied):**

```bash title="Show each file as it's copied"
cp -v *.txt ~/documents/
# 'file1.txt' -> '/home/brad/documents/file1.txt'
# 'file2.txt' -> '/home/brad/documents/file2.txt'
```

**Interactive mode (ask before overwriting):**

```bash title="Prompt before overwriting existing files"
cp -i resume.txt ~/documents/
# cp: overwrite '/home/brad/documents/resume.txt'? y
```

Type `y` to overwrite, `n` to skip.

**Combine options:**

```bash title="Recursive, verbose, interactive"
cp -rvi old-project/ new-project/
```

### Common `cp` Patterns

**Backup before editing:**

```bash
cp config.yaml config.yaml.bak
nano config.yaml  # Edit the file
```

If you break it, restore from `.bak`.

**Copy to current directory from elsewhere:**

```bash
cp /etc/hosts .
```

The `.` means "current directory."

**Duplicate directory structure:**

```bash
cp -r /var/www/html ~/backup-$(date +%Y%m%d)
```

Copies entire web directory to `backup-20241214/`.

## Moving and Renaming: `mv`

`mv` does two things:

1. **Move files/directories** to a different location
2. **Rename files/directories**

It's the same command because *renaming is just moving to a new name*.

### Rename a File

```bash title="Rename a file"
mv oldname.txt newname.txt
```

`oldname.txt` no longer exists - it's now `newname.txt`.

### Rename a Directory

```bash title="Rename a directory"
mv old-project new-project
```

### Move a File

```bash title="Move file to different directory"
mv report.txt ~/documents/
```

`report.txt` is now in `~/documents/` with the same name.

### Move and Rename

```bash title="Move file and give it a new name"
mv report.txt ~/documents/quarterly-report.txt
```

### Move Multiple Files

```bash title="Move several files to a directory"
mv file1.txt file2.txt file3.txt ~/documents/
```

**Last argument must be a directory.**

### Move with Wildcards

```bash title="Move all .log files"
mv *.log ~/old-logs/
```

### Move Directories

**No `-r` needed for `mv`** (unlike `cp`):

```bash title="Move entire directory"
mv old-project ~/archive/
```

### Useful `mv` Options

**Interactive (ask before overwriting):**

```bash title="Prompt before overwriting"
mv -i important.txt ~/documents/
# mv: overwrite '/home/brad/documents/important.txt'? y
```

**Verbose:**

```bash title="Show what's being moved"
mv -v *.txt ~/documents/
# renamed 'file1.txt' -> '/home/brad/documents/file1.txt'
# renamed 'file2.txt' -> '/home/brad/documents/file2.txt'
```

**No-clobber (never overwrite):**

```bash title="Skip if destination exists"
mv -n file.txt ~/documents/
```

If `~/documents/file.txt` exists, nothing happens.

### Common `mv` Patterns

**Reorganize files:**

```bash
mv ~/Downloads/*.pdf ~/documents/pdfs/
```

**Rename with date:**

```bash
mv log.txt log-$(date +%Y%m%d).txt
# Becomes: log-20241214.txt
```

**Lowercase to uppercase:**

```bash
mv readme.txt README.txt
```

**Fix typos:**

```bash
mv imporatnt.txt important.txt
```

## Deleting Files: `rm`

`rm` stands for "remove." **It's permanent. No undo. No recycle bin.**

Use carefully.

### Remove a Single File

```bash title="Delete a file"
rm unwanted.txt
```

Gone. Forever.

### Remove Multiple Files

```bash title="Delete several files"
rm file1.txt file2.txt file3.txt
```

### Remove with Wildcards

```bash title="Delete all .tmp files"
rm *.tmp
```

**Be careful with wildcards!**

```bash
rm *  # Deletes EVERYTHING in current directory
```

Check with `ls` first:

```bash
ls *.tmp     # See what will be deleted
rm *.tmp     # Now delete them
```

### Remove Directories (Recursive)

`rm` can delete directories if you use `-r` (recursive):

```bash title="Delete directory and all contents"
rm -r old-project/
```

**This deletes the directory and everything inside it. Permanently.**

### Useful `rm` Options

**Interactive (ask before each deletion):**

```bash title="Confirm each file"
rm -i *.txt
# rm: remove regular file 'file1.txt'? y
# rm: remove regular file 'file2.txt'? n
# rm: remove regular file 'file3.txt'? y
```

**Force (no prompts, ignore nonexistent files):**

```bash title="Force deletion without prompts"
rm -f protected-file.txt
```

Bypasses warnings. Use with caution.

**Verbose (show what's being deleted):**

```bash title="Show each deletion"
rm -v *.log
# removed 'app.log'
# removed 'error.log'
```

**Combine for safety:**

```bash title="Interactive, verbose, recursive"
rm -riv old-project/
```

Shows each file and asks for confirmation before deleting.

### The Nuclear Option (DO NOT DO THIS)

```bash
sudo rm -rf /
```

**This command destroys your entire system.** Don't run it. Ever.

- `sudo` - run as root (full permissions)
- `rm` - remove
- `-r` - recursive (directories and contents)
- `-f` - force (no confirmation)
- `/` - starting at root (everything)

It's the Linux equivalent of "delete system32" memes. Except it actually works.

Modern Linux has safeguards, but don't test them.

### Safer Deletion Practices

**1. Use `ls` before `rm`:**

```bash
ls *.tmp        # Check what will be deleted
rm *.tmp        # Delete it
```

**2. Use `-i` when learning:**

```bash
alias rm='rm -i'   # Add to ~/.bashrc
```

Now `rm` always asks for confirmation.

**3. Use trash instead:**

Install `trash-cli`:

```bash
sudo apt install trash-cli
```

Now use `trash` instead of `rm`:

```bash
trash unwanted.txt
```

It goes to trash, and you can restore it with `trash-restore`.

**4. Double-check before hitting Enter:**

```bash
rm -rf /home/brad/old-files/   # Correct
rm -rf / home/brad/old-files/   # WRONG - extra space deletes everything!
```

## Common File Management Workflows

### Organize Downloaded Files

```bash
cd ~/Downloads
ls
mkdir -p ~/documents/pdfs ~/pictures ~/videos
mv *.pdf ~/documents/pdfs/
mv *.jpg *.png ~/pictures/
mv *.mp4 *.mkv ~/videos/
```

### Create Project Structure

```bash
mkdir -p ~/projects/new-app/{src,tests,docs,config}
cd ~/projects/new-app
```

### Backup Before Editing

```bash
cp config.yaml config.yaml.$(date +%Y%m%d)
nano config.yaml
```

Now you have `config.yaml.20241214` as backup.

### Clean Up Old Files

```bash
cd ~/old-project
ls -lt        # See files by date
rm -i *.tmp   # Remove temp files interactively
rm -r build/  # Remove build directory
```

### Rename Multiple Files

Bash doesn't have bulk rename built-in, but you can loop:

```bash title="Add prefix to all .txt files"
for file in *.txt; do
    mv "$file" "backup-$file"
done
```

Or use the `rename` command:

```bash
sudo apt install rename
rename 's/\.txt$/.md/' *.txt  # Change .txt to .md
```

## Common Mistakes

### Overwriting Files Accidentally

```bash
cp important.txt documents/
# Oops, documents/important.txt already existed and is now overwritten
```

**Prevention:** Use `-i` flag or check first with `ls`.

### Deleting the Wrong Thing

```bash
rm -r project/  # Meant projects/
```

**Prevention:** Use Tab completion. Use `-i` flag when learning.

### Forgetting Path Separators

```bash
mkdir -p project/src       # Creates project/src/ in current directory
mkdir -p /project/src      # Tries to create /project/src/ at root (fails without sudo)
```

**Watch the leading `/`** - it means starting from root.

### Wildcards Matching Too Much

```bash
rm *.txt      # Wanted to delete draft*.txt
```

**Prevention:** Use `ls *.txt` first to see what matches.

## Practice Exercises

**Exercise 1: Create and organize**

```bash
mkdir -p practice/{docs,images,code}
cd practice
touch docs/notes.txt docs/report.txt
touch images/photo.jpg images/diagram.png
touch code/script.sh code/app.py
ls -R
```

**Exercise 2: Copy and rename**

```bash
cp docs/notes.txt docs/notes-backup.txt
cp -r docs backup-docs
mv images photos
ls
```

**Exercise 3: Safe deletion**

```bash
cd practice
ls code/
rm -i code/script.sh
ls code/
```

**Exercise 4: Reorganize**

```bash
mkdir archive
mv backup-docs archive/
mv photos archive/
ls
ls archive/
```

**Exercise 5: Clean up**

```bash
cd ..
rm -r practice/
```

## Key Takeaways

- **`mkdir -p`** - Create directories, including parents
- **`cp source dest`** - Copy files; use `-r` for directories
- **`mv source dest`** - Move or rename; works on files and directories
- **`rm file`** - Delete files; use `-r` for directories
- **`rm` is permanent** - no undo, no trash
- **Use `-i` for safety** - interactive mode asks before overwriting/deleting
- **Use `-v` for visibility** - see what's happening
- **Check with `ls` before `rm`** - see what you're about to delete
- **Tab completion prevents typos** - use it constantly

File management on Linux is powerful and fast once you're comfortable with these commands. The lack of a graphical file manager isn't a limitation - it's an advantage. You can batch operations, script repetitive tasks, and move faster than clicking through folders.

**The muscle memory comes with practice.** Create throwaway files and directories. Practice copying, moving, deleting. Get comfortable with the commands in a safe environment before using them on important data.

Let's keep building skills.
