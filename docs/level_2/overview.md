# Level 2: Finding & Filtering

!!! quote "Because searching is half of Linux life"

## Welcome to Level 2

You can navigate directories and manage files. Great start! But here's the reality: Linux systems have thousands of files, millions of lines of logs, and you need to find specific needles in these massive haystacks.

**This level teaches you how to search.** Find files by name. Search inside files for text. Filter and shape output. Chain commands together like a pro.

These are the tools you'll use every single day to find what you're looking for.

## What You'll Master

Finding things and filtering output is a core Linux skill:

- **Searching for files** - `find`, `locate`, `which`
- **Looking inside files** - `grep` (your new best friend)
- **Shaping output** - `sort`, `uniq`, `wc`
- **Cutting text** - `cut`, `awk`, `sed` (gentle intro)
- **Chaining commands** - Pipes and command combinations

## Who This Level Is For

**Perfect for:**

- Anyone who's completed Level 1
- People who know basic commands but struggle to find things
- Developers who need to search logs and configuration files
- Anyone tired of manually scrolling through files

**Prerequisites:**

You should be comfortable with Level 1 basics - navigating directories, viewing files, basic command-line usage. If you're not there yet, go back to [Level 1: Everyday Navigation](../level_1/overview.md).

## The Skills

Work through these in order to build your search superpowers:

1. **[Finding Files](finding_files.md)** - find, locate, which, xargs
2. **[Searching Inside Files](grep_basics.md)** - grep fundamentals
3. **[Sorting and Counting](sort_uniq_wc.md)** - sort, uniq, wc
4. **[Text Extraction](cut_awk.md)** - cut and awk basics
5. **[Text Transformation](sed_basics.md)** - sed for simple edits
6. **[Chaining Commands with Pipes](pipes.md)** - Combine tools like a wizard

## What's Next?

Once you can find files and filter their contents, you're ready for [Level 3: Processes & Permissions](../level_3/overview.md). That's where you'll learn what's actually running on your system and how Linux controls access to files.

## The Philosophy

**Search tools save time.** You could manually browse through `/var/log/` reading every file, or you could `grep` for "error" across all logs in seconds. You could open a 10,000-line config file, or you could `grep` for the exact setting you need.

The command line becomes powerful when you stop doing things manually and start letting tools do the work.

## Real-World Scenarios

These skills directly map to real tasks:

- "Where's that config file?" → `find`
- "When did the error first appear?" → `grep` with timestamps
- "How many times did this event happen?" → `grep | wc -l`
- "Show me unique IP addresses" → `cut | sort | uniq`
- "Find all Python files changed today" → `find` with time filters

Learn these tools, and you'll solve these problems in seconds.

Let's start searching.
